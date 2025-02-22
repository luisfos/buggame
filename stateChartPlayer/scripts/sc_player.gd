extends RigidBody2D

# TODO
# create a PID debugger for input / output 
# see https://www.youtube.com/watch?v=6EcxGh1fyMw&list=LL&index=1&pp=gAQBiAQB
# limit jumping only while grounded
# add faster fall speed?
# how to limit our speed 

# all player external parms in CAPS
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var MOVE_SPEED: float = 0.5 # mult on PID output
@export var JUMP_SPEED: float = 500.0
# @export var ACCEL_TIME := 0.1 # dont need atm
const TERMINAL_SPEED := 1000.0 # to change later, not sure if need for PID

# maybe references should be prefixed?
@onready var rayAnchor : Node2D  = $anchor
@onready var rayL : RayCast2D  = $anchor/rayL
@onready var rayC : RayCast2D  = $anchor/rayC
@onready var rayR : RayCast2D  = $anchor/rayR
@onready var pid_target : Node2D = $PID_target
@onready
var _state_chart = $StateChart
@onready var thruster : Node2D = $thruster

# persisting variables, maybe prefix with _?
var _is_on_floor : bool = false
var current_state : String = "" # is this used?

var pid_movement = PIDFloat.new(1.0, 0.5, 0.1,
				-TERMINAL_SPEED, TERMINAL_SPEED,
				10.0, PIDFloat.DerivativeMeasurement.VELOCITY)

var pid_thruster := PIDFloat.new(1.0, 0.01, 0.0, -300, 0, 300, PIDFloat.DerivativeMeasurement.VELOCITY)

# -45 to 45
# this is in degrees, must convert output to radians!
var pid_angle = PIDFloat.new(1.5, 0.005, 0.05,
				 -45, 45, 999, PIDFloat.DerivativeMeasurement.VELOCITY)

var current_pid : PIDFloat = pid_thruster
var output_thrust_force : Vector2 = Vector2.ZERO
var output_movement_force : Vector2 = Vector2.ZERO

# timers
var timer_jump_held := 0.3

#@onready
#var animations = $animations

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.lock_rotation = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	update_is_on_floor()
	
		
func update_is_on_floor() -> bool:	
	rayAnchor.rotation = -rotation	
	var floor_max_angle = -0.75
	var hitL: bool = rayL.is_colliding()
	var hitC: bool = rayC.is_colliding()
	var hitR: bool = rayR.is_colliding()
	if hitL:
		hitL = rayL.get_collision_normal().y < floor_max_angle
	if hitC:
		hitC = rayC.get_collision_normal().y < floor_max_angle
	if hitR:
		hitR = rayR.get_collision_normal().y < floor_max_angle
	
	_is_on_floor = maxi(maxi(hitL, hitR), hitC)
	return _is_on_floor
	
	
func _on_movement_state_physics_processing(delta: float) -> void:	
	var input_x: float = Input.get_axis("left","right")		
	pid_target.position.x = (input_x * 40)
	var error := Vector2.ZERO
	error = pid_target.global_position - global_position	
	
	# when to apply correction, including drag
	if error.length_squared() != 0:# or player.is_on_floor:
		# var correction: Vector2 = pid_normal.update(error, delta) 
		var correction := Vector2.ZERO
		correction.x = pid_movement.update(delta, global_position.x, pid_target.global_position.x)
		output_movement_force = correction * MOVE_SPEED
		self.apply_central_impulse(correction * MOVE_SPEED) 


func _on_grounded_state_physics_processing(delta: float) -> void:
	
	if Input.is_action_just_released("space"):
		_is_on_floor = false
		self.apply_central_impulse(Vector2(0,-JUMP_SPEED))		
		_state_chart.send_event("jump")

	if not _is_on_floor: # fell
		_state_chart.send_event("airborne")



func _on_airborne_state_physics_processing(delta: float) -> void:
	print("on airborne ", Time.get_ticks_msec()) 
	# check if jump held, if so, go to helicopter state
	if Input.is_action_pressed("space"):
		timer_jump_held -= delta
		if timer_jump_held <= 0:
			_state_chart.send_event("helicopter")
	else:
		timer_jump_held = 0.3

	
	# if we send event above, will we reach this code?
	if _is_on_floor: # fell
		_state_chart.send_event("grounded")
	


func _on_heli_thrusting_state_physics_processing(delta: float) -> void:
	# while thrusting in helicopter mode
	if Input.is_action_pressed("space"):			
		pid_target.rotation = -rotation		
		pid_target.position.y = -50
		
		var local_up : Vector2 = -global_transform.y.normalized()
		var direction : Vector2 = pid_target.position.normalized()
		var dir_weight: float = max(local_up.dot(direction),0)
		direction *= dir_weight

		# less force if sideways
		# local_up = pid_target.position  * max(-local_up.dot(pid_target.position), 0)
		# self.apply_central_force(local_up * 1) 

		# determine target velocity from distance to pid_target
		var target_speed: float = -50.0 
		var current_speed: float = self.linear_velocity.y
		var thrust_force: float = pid_thruster.update(delta, current_speed, target_speed)
		# print("direction: ", direction)
		# print("force: ", thrust_force)

		output_thrust_force = -direction * thrust_force
		self.apply_central_force(-direction * thrust_force * 100)
		# self.apply_central_force(Vector2(0,-1300.0)) # temp
				
	else:
		pid_target.position = Vector2.ZERO
		_state_chart.send_event("release")

	


func _on_thrusting_state_entered() -> void:
	thruster.visible = true
	

func _on_thrusting_state_exited() -> void:
	thruster.visible = false
	self.output_thrust_force = Vector2.ZERO
	self.pid_thruster.reset()
	

func _on_helicopter_state_entered() -> void:
	self.lock_rotation = false


func _on_helicopter_state_exited() -> void:
	pass


func _on_heli_falling_state_physics_processing(delta: float) -> void:
	if Input.is_action_pressed("space"):
		_state_chart.send_event("thrust")

	if _is_on_floor: # fell
		_state_chart.send_event("grounded")
	


func _on_movement_state_entered() -> void:
	self.rotation = 0
	pid_target.rotation = 0
	self.lock_rotation = true
	


func _on_helicopter_state_physics_processing(delta: float) -> void:
	# stabilise rotation

	var input_x: float = Input.get_axis("left","right")
	
	var too_bent: bool = self.rotation_degrees < -50 or self.rotation_degrees > 50
	if input_x != 0 and too_bent: # dont go past
		input_x = 0
	pid_target.position.x = input_x * 10 # temp

	var current_angle = rotation_degrees # world space rotation?
	var target_angle = (input_x * 45.0) # + current_angle # also world space rotation
	
	var angular_output: float = pid_angle.update_angle(delta, current_angle, target_angle)	

	self.apply_torque(angular_output*100)	

	


func _on_movement_state_exited() -> void:
	self.pid_movement.reset()
	self.output_movement_force = Vector2.ZERO
