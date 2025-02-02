extends CharacterBody2D

enum State {
	idle,
	run,
	jump,
	falling
}

# state variables
# godot 2D is y down. gravity is positive. jump is negative
var current_state: State = State.idle
# var velocity: Vector2 = Vector2.ZERO

@export var maxSpeed: float = 200.0
@export var maxAccel: float = 2000.0
@export var maxDecel: float = 3000.0
@export var maxAirAccel: float = 600.0
@export var maxAirDecel: float = 100.0
@export var maxTurnSpeed: float = 2000.0
@export var maxAirTurnSpeed: float = 2000.0
var min_speed_unit: float = 5.0
var jump_force: float = -400.0
var gravity: float = 1000.0

# references to nodes
@onready var animations = $animations
@onready var colshape = $colshape
@onready var vis = $Control/stateVis.get_theme_stylebox("panel")
# this panel is the name of the stylebox

func _ready() -> void:
	pass
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
			velocity.y = jump_force
			vis.set_bg_color(Color.YELLOW)
			animations.play("jump")
		State.falling:
			vis.set_bg_color(Color.LIME_GREEN)
			animations.play("falling")

func _physics_process(delta: float) -> void:
	# runs every frame
	var movement_x = Input.get_axis('left', 'right')   

	match current_state:
		State.idle:
			state_idle()
		State.run:	
			state_run(delta, movement_x)			
		State.jump:
			velocity.y += gravity * delta
			if velocity.y > 0:
				change_state(State.falling)
			side_movement(delta, movement_x)
		State.falling:
			velocity.y += gravity * delta
			if is_on_floor():
				if abs(velocity.x) > min_speed_unit:
					change_state(State.run)
				else:
					change_state(State.idle)
			side_movement(delta, movement_x)
	
	move_and_slide()


func state_idle() -> void:	
	if not is_on_floor():
		change_state(State.falling)
		return			

	if Input.is_action_just_pressed("up"):
		velocity.y = -jump_force
		change_state(State.jump)
		return

	var movement = Input.get_axis('left', 'right') * maxSpeed     
	if movement != 0 and is_on_floor():
		change_state(State.run)

func state_run(delta, movement_x) -> void:
	if is_on_floor() and movement_x == 0 and abs(velocity.x) < min_speed_unit:
		change_state(State.idle)	
					
	if not is_on_floor():
		change_state(State.falling)
		return

	if Input.is_action_just_pressed("up"):
		velocity.y = -jump_force
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
	
