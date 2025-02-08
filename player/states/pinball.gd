extends StateNode

##########################################################
# This is the player's movement controller.
# Instead of placing all of the movement stuff inside
# of the player, we move the code to a separate component
##########################################################

@export_group("Speed Values")


func enter() -> void:	
	player.freeze = false # ensure has physics

func exit() -> void:
	pass
	# maybe this needs to be only handled by enter of other states?
	# player.freeze = false # allow physics

func process_input(event: InputEvent) -> String:
	if Input.is_action_just_pressed('up') and player.is_on_floor:
		return "jump"			

	if Input.is_action_just_pressed('space'):
		return "movement"
		
	return NO_CHANGE
	

func process_physics(delta: float) -> String:
	
	var target_x := Input.get_axis("left", "right") * player.MOVE_SPEED	
	# if abs(target_x) > 0:
	# if true:
	# remember this will also apply drag 
	var vel_error := Vector2.ZERO
	vel_error.x = target_x - player.linear_velocity.x	
	
	# when to apply correction, including drag
	if target_x != 0 or player.is_on_floor:
		var correction_impulse: Vector2 = player.pid.update(vel_error, delta) * 0.1
		player.apply_central_impulse(correction_impulse) 
		# print("impulse:", correction_impulse)	

	return NO_CHANGE
	
func process_frame(delta: float) -> String:	
	return NO_CHANGE

# func process_integrate_forces(state: PhysicsDirectBodyState2D) -> String:
# 	var linear_velocity = player.linear_velocity
# 	var target_velocity: float

# 	target_velocity = Input.get_axis("left", "right")	
# 	target_velocity *= speed
# 	# Move the player
# 	linear_velocity.x = move_toward(linear_velocity.x, target_velocity, speed * state.get_step())
# 	player.linear_velocity = linear_velocity

# 	return NO_CHANGE
