extends StateNode

##########################################################
# This is the player's movement controller.
# Instead of placing all of the movement stuff inside
# of the player, we move the code to a separate component
##########################################################

@export_group("Speed Values")
@export var JUMP_FORCE := 700.0


func enter() -> void:	
	player.linear_velocity.y = -JUMP_FORCE

func exit() -> void:
	pass	


func process_physics(delta: float) -> String:	

	var input_x: float = Input.get_axis("left","right")	 * player.MOVE_SPEED

	if player.freeze: # Kinematic Mode
		player.linear_velocity.y += player.GRAVITY * delta
		
		if player.linear_velocity.y > 0:
			return "movement"

		player.linear_velocity.x = input_x
		player.move_and_collide(player.linear_velocity * delta)				

	else: # RigidBody Mode
		return "pinball"	

	# if input_x != 0:		
	# 	# flip anim direction
	# 	pass	
	
	return NO_CHANGE
	
func process_frame(delta: float) -> String:	
	return NO_CHANGE
