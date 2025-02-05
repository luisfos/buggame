extends StateNode
#class_name Movement

##########################################################
# This is the player's movement controller.
# Instead of placing all of the movement stuff inside
# of the player, we move the code to a separate component
##########################################################

@export_group("Speed Values")
@export var max_speed := 100.0
@export var acceleration_time := 0.1

@onready var body : CharacterBody2D  = $"../../CharacterBody2D"
@onready var player : Node2D  = self.get_owner()

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity") # 980 

func Enter() -> void:
	body.transform = player.transform
	body.set_process(true)	
	body.visible = true	

func Exit() -> void:
	body.visible = false
	body.set_process(false)	

func PhysicsProcess(delta):
	# Read the player's current velocity
	var velocity = body.velocity
	var input_x = Input.get_axis("left","right")
	
	print(input_x)
	
	# Apply any changes to velocity
	velocity.x = velocity.x.move_toward(input_x*max_speed, (1.0 / acceleration_time) * delta * max_speed)
	
	velocity.y += GRAVITY * delta	
	
	# Reassign velocity and move the player
	body.velocity = velocity
	print(velocity)
	body.move_and_slide()
	
func Update(delta: float):
	player.transform = body.transform
	pass
