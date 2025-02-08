extends StateNode

##########################################################
# This is the player's movement controller.
# Instead of placing all of the movement stuff inside
# of the player, we move the code to a separate component
##########################################################


@export_group("Speed Values")
@export var acceleration_time := 0.1

func enter() -> void:	
	player.freeze = true # ensure no physics

func exit() -> void:
	pass
	# maybe this needs to be only handled by enter of other states?
	# player.freeze = false # allow physics

func process_input(event: InputEvent) -> String:
	if Input.is_action_just_pressed('up') and player.is_on_floor:
		return "jump"			

	if Input.is_action_just_pressed('space'):
		return "pinball"		
		
	return NO_CHANGE
	

func process_physics(delta: float) -> String:	
	var ms : float = player.MOVE_SPEED

	# Read the player's current velocity
	var velocity = player.linear_velocity
	var input_x: float = Input.get_axis("left","right")	
	
	# Apply any changes to velocity
	velocity.x = move_toward(velocity.x, input_x*ms, (1.0 / acceleration_time) * ms)	

	if not player.is_on_floor:
		velocity.y += player.GRAVITY * delta
	else:
		velocity.y = 0
	
	# Reassign velocity and move the player
	player.linear_velocity = velocity
	player.move_and_collide(velocity * delta)
	return NO_CHANGE
	
func process_frame(delta: float) -> String:	
	return NO_CHANGE
