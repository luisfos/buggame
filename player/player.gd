extends CharacterBody2D



enum enumState {
	idle,
	run,
	jump,
	falling
}

# state variables
# godot 2D is y down. gravity is positive. jump is negative
var current_state: enumState = enumState.idle
# var velocity: Vector2 = Vector2.ZERO

# initial values, shouldnt basically be Constants
@export var maxSpeed: float = 200.0
@export var maxAccel: float = 2000.0
@export var maxDecel: float = 3000.0
@export var maxAirAccel: float = 600.0
@export var maxAirDecel: float = 400.0
@export var maxTurnSpeed: float = 2000.0
@export var maxAirTurnSpeed: float = 2000.0
var min_speed_unit: float = 5.0

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") # 980 

var jump_height: float = 50.0
var jump_apex_time: float = 0.2
var jump_down_mult: float = 2.0

# helper variables to manage over time
var current_grav_mult = 1.0
var gravity_scale = 1.0 # is built in to RigidBody2D

# references to nodes
@onready var animations = $animations
@onready var colshape = $colshape
@onready var vis = $Control/stateVis.get_theme_stylebox("panel")


# this panel is the name of the stylebox

func _ready() -> void:	
	pass

func change_state(new_state: enumState) -> void:
	# runs once on state change
	print("changing state from: ", current_state, ", 	to: ", new_state)
	current_state = new_state
	match current_state:
		enumState.idle:
			vis.set_bg_color(Color.AQUA)
			animations.play("idle")
		enumState.run:
			vis.set_bg_color(Color.BLUE)			
			animations.play("run")
		enumState.jump:
			jump_impulse()
			vis.set_bg_color(Color.YELLOW)
			animations.play("jump")
		enumState.falling:
			vis.set_bg_color(Color.LIME_GREEN)
			animations.play("falling")

func _physics_process(delta: float) -> void:
	# runs every frame
	var movement_x = Input.get_axis('left', 'right')   	

	match current_state:
		enumState.idle:
			state_idle(movement_x)
		enumState.run:	
			state_run(delta, movement_x)			
		enumState.jump:
			vert_movement(delta)
			if velocity.y > 0:
				change_state(enumState.falling)
			side_movement(delta, movement_x)
		enumState.falling:
			vert_movement(delta)
			if is_on_floor():
				if abs(velocity.x) > min_speed_unit:
					change_state(enumState.run)
				else:
					change_state(enumState.idle)
			side_movement(delta, movement_x)	
	
	
	move_and_slide()


func state_idle(movement_x) -> void:	
	if not is_on_floor():
		change_state(enumState.falling)
		return			

	if Input.is_action_just_pressed("up"):		
		change_state(enumState.jump)
		return
	
	if movement_x != 0 and is_on_floor():
		change_state(enumState.run)

func state_run(delta, movement_x) -> void:
	if is_on_floor() and movement_x == 0 and abs(velocity.x) < min_speed_unit:
		change_state(enumState.idle)	
					
	if not is_on_floor():
		change_state(enumState.falling)
		return

	if Input.is_action_just_pressed("up"):		
		change_state(enumState.jump)
		return

	side_movement(delta, movement_x)

func side_movement(delta, movement_x) -> void:
	# run in multiple states, run falling etc
	# modifies velocity
	var accel = maxAccel if is_on_floor() else maxAirAccel
	var decel = maxDecel if is_on_floor() else maxAirDecel
	var turnSpeed = maxTurnSpeed if is_on_floor() else maxAirTurnSpeed
	var maxSpeedChange: float = 0.0

	if movement_x != 0:
		if sign(velocity.x) != sign(movement_x): 
			# turn to opposite direction			
			maxSpeedChange = turnSpeed * delta
		else:
			# accelerate
			maxSpeedChange = accel * delta
	else:
		# decelerate
		maxSpeedChange = decel * delta
	
	velocity.x = move_toward(velocity.x, movement_x * maxSpeed, maxSpeedChange)
	
func vert_movement(delta) -> void:
	# handles movement in y direction
	# no state changes in here.
	
	# velocity.y += GRAVITY * delta
	var new_gravity = (2.0 * jump_height) / (jump_apex_time * jump_apex_time)
	gravity_scale = (new_gravity / GRAVITY) * current_grav_mult

	if velocity.y == 0:
		current_grav_mult = 1.0
	elif velocity.y > min_speed_unit:		
		current_grav_mult = jump_down_mult	

	velocity.y += GRAVITY * gravity_scale * delta 
	

func jump_impulse() -> void:
	if is_on_floor(): # this check may be redundant
		var jumpSpeed = -sqrt( 2.0 * GRAVITY * gravity_scale * jump_height )
		
		print("jumpSpeed: ", jumpSpeed)
		print("gs: ", gravity_scale)
		if velocity.y < 0: # while rising
			jumpSpeed = min(jumpSpeed - velocity.y, 0)
		elif velocity.y > 0: # while falling
			jumpSpeed -= abs(velocity.y)
		
		velocity.y += jumpSpeed	


#######
# jims shit grapple hook
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 10
@export var hook: StaticBody2D
@export var pinjoint : PinJoint2D
@onready var line = $Line2D
var hooked = false
@onready var line_end = hook.get_node("Marker2D")

func _process(delta: float) -> void:
	print(rad_to_deg(get_angle_to(get_global_mouse_position())))
	if Input.is_action_just_pressed("shoot") and not hooked:
		
		hooked = true
		ray_cast_2d.target_position = to_local(get_global_mouse_position())
		ray_cast_2d.force_raycast_update()
		if ray_cast_2d.is_colliding():
			#get values from raycast
			var hook_pos = ray_cast_2d.get_collision_point()
			var collider = ray_cast_2d.get_collider()
			
			#if the ray collides with a hookable object, move pinjoint and hook to it
			if collider.is_in_group("Hookable"):
				pinjoint.global_position = hook_pos
				hook.global_position = hook_pos
				pinjoint.node_b = get_path_to(hook)
				#rotate the hook so it is the right angle
				var direction = hook_pos - global_position
				hook.rotation = direction.angle()

	elif Input.is_action_just_released("shoot") and hooked:
		hooked = false	
		pinjoint.node_b = NodePath("")	

	
	if hooked:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(line_end.global_position))
	else:
		line.clear_points()
		
	var grounded = is_on_floor()
	#this stuff all errors.. probably cause player isnt a rigid body like in the tutorial? idk
	#if Input.is_action_pressed("retract") and hooked:
		#retract code here
		
	#basic platformer code below
	#if Input.is_action_pressed("right") and (grounded or hooked):
	#	apply_central_impulse(Vector2.RIGHT)
	#if Input.is_action_pressed("left") and (grounded or hooked):
	#	apply_central_impulse(Vector2.LEFT)
	#if Input.is_action_just_pressed("jump") and grounded:
	#	apply_central_impulse(Vector2.UP * 100)

#######
