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
var move_speed: float = 200.0
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
	# var movement = Input.get_axis('left', 'right') * move_speed     
	match current_state:
		State.idle:
			state_idle()
		State.run:	
			state_run()			
		State.jump:
			velocity.y += gravity * delta
			if velocity.y > 0:
				change_state(State.falling)
		State.falling:
			velocity.y += gravity * delta
			if is_on_floor():
				change_state(State.idle)
	
	move_and_slide()


func state_idle() -> void:	
	if not is_on_floor():
		change_state(State.falling)
		return			

	if Input.is_action_just_pressed("up"):
		velocity.y = -jump_force
		change_state(State.jump)
		return

	var movement = Input.get_axis('left', 'right') * move_speed     
	if movement != 0 and is_on_floor():
		change_state(State.run)

func state_run() -> void:
	var movement = Input.get_axis('left', 'right') * move_speed     
	if movement == 0 and is_on_floor():
		change_state(State.idle)	
					
	if not is_on_floor():
		change_state(State.falling)
		return

	if Input.is_action_just_pressed("up"):
		velocity.y = -jump_force
		change_state(State.jump)
		return

	velocity.x = movement
	
