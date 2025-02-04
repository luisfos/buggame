extends CharacterBody2D

enum State {
	idle,
	run,
	jump,
	falling,
	pinball,
}

# state variables
# godot 2D is y down. gravity is positive. jump is negative
var current_state: State = State.idle
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
var gravity_scale = 1.0
var bullet_time_input_count = 0
var bullet_time_direction: Vector2i = Vector2i.ZERO

# references to nodes
@onready var animations = $animations
@onready var colshape = $colshape
@onready var vis = $Control/stateVis.get_theme_stylebox("panel")
@onready var bullet_time_line2D: Line2D = $Control/bullettimeLine

# this panel is the name of the stylebox

@onready var bullet_time_timer = Timer.new()

func _ready() -> void:
	add_child(bullet_time_timer)
	bullet_time_timer.one_shot = true	
	bullet_time_timer.connect("timeout", Callable(self, "_on_bullet_time_timeout"))
	# pass
	#var sb = vis.
	#print(sb)

func change_state(new_state: State) -> void:
	# runs once on state change
	print("changing state from: ", current_state, ", 	to: ", new_state)
	current_state = new_state
	match current_state:
		State.idle:
			vis.set_bg_color(Color.AQUA)
			animations.play("idle")
		State.run:
			vis.set_bg_color(Color.BLUE)			
			animations.play("run")
		State.jump:
			jump_impulse()
			vis.set_bg_color(Color.YELLOW)
			animations.play("jump")
		State.falling:
			vis.set_bg_color(Color.LIME_GREEN)
			animations.play("falling")

func _physics_process(delta: float) -> void:
	# runs every frame
	var movement_x = Input.get_axis('left', 'right')   
	var space_pressed = Input.is_action_just_released("space")

	if space_pressed and bullet_time_timer.is_stopped():
		enter_bullettime()

	match current_state:
		State.idle:
			state_idle(movement_x)
		State.run:	
			state_run(delta, movement_x)			
		State.jump:
			vert_movement(delta)
			if velocity.y > 0:
				change_state(State.falling)
			side_movement(delta, movement_x)
		State.falling:
			vert_movement(delta)
			if is_on_floor():
				if abs(velocity.x) > min_speed_unit:
					change_state(State.run)
				else:
					change_state(State.idle)
			side_movement(delta, movement_x)
		State.pinball:
			state_pinball(delta)		
			
	
	if not bullet_time_timer.is_stopped():
		during_bullettime()
	
	if current_state != State.pinball:
		move_and_slide()


func state_idle(movement_x) -> void:	
	if not is_on_floor():
		change_state(State.falling)
		return			

	if Input.is_action_just_pressed("up"):		
		change_state(State.jump)
		return
	
	if movement_x != 0 and is_on_floor():
		change_state(State.run)

func state_run(delta, movement_x) -> void:
	if is_on_floor() and movement_x == 0 and abs(velocity.x) < min_speed_unit:
		change_state(State.idle)	
					
	if not is_on_floor():
		change_state(State.falling)
		return

	if Input.is_action_just_pressed("up"):		
		change_state(State.jump)
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

	# print("current velocity: ", velocity.x)
	# print("target velocity: ", movement_x * maxSpeed)
	# print("maxSpeedChange: ", maxSpeedChange)
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

func state_pinball(delta) -> void:
	if is_on_floor():
		if velocity.is_zero_approx():
			change_state(State.idle)
			return
		elif velocity.length_squared() < min_speed_unit*10:
			change_state(State.run)
			return
	elif velocity.y < min_speed_unit: # falling?
		pass

	pinball_movement(delta)
	
func pinball_movement(delta) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())

	side_movement(delta, 0.0)
	vert_movement(delta)
		


func enter_bullettime() -> void:
	# print("entering bullet time")
	# slow down time for 1 second
	Engine.time_scale = 0.05
	bullet_time_direction = Vector2i.ZERO
	bullet_time_input_count = 0
	bullet_time_timer.start(3.0 * Engine.time_scale)	
	bullet_time_line2D.visible = true

	
func during_bullettime() -> void:	
	if bullet_time_input_count == 3:
		exit_bullettime()		
		return 		

	# listen for 3 direction presses		
	if Input.is_action_just_released("left") and bullet_time_input_count < 3:
		bullet_time_input_count += 1
		bullet_time_direction.x -= 1
	if Input.is_action_just_released("right") and bullet_time_input_count < 3:
		bullet_time_input_count += 1
		bullet_time_direction.x += 1
	if Input.is_action_just_released("up") and bullet_time_input_count < 3:
		bullet_time_input_count += 1
		bullet_time_direction.y -= 1
	if Input.is_action_just_released("down") and bullet_time_input_count < 3:
		bullet_time_input_count += 1
		bullet_time_direction.y += 1

	bullet_time_line2D.set_point_position(1, bullet_time_direction * 30)

func exit_bullettime() -> void:
	# print("exiting bullet time")
	# if 3 directions are pressed, move in that direction
	velocity = bullet_time_direction * maxSpeed * 2	
	change_state(State.pinball)
	bullet_time_timer.stop()
	bullet_time_line2D.visible = false
	Engine.time_scale = 1.0
	
func _on_bullet_time_timeout() -> void:
	# Restore normal time scale	
	Engine.time_scale = 1.0
