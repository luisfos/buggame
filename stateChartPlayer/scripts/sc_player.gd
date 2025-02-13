extends RigidBody2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var MOVE_SPEED: float = 100.0
@export var ACCEL_TIME := 0.1
const TERMINAL_SPEED := 1000.0

@onready var rayAnchor : Node2D  = $anchor
@onready var rayL : RayCast2D  = $anchor/rayL
@onready var rayC : RayCast2D  = $anchor/rayC
@onready var rayR : RayCast2D  = $anchor/rayR

@onready var pid_target : Node2D = $PID_target

var is_on_floor : bool = false
var current_state : String = ""
var pid := PID_2D.new(1.0, 0.0, 0.1, TERMINAL_SPEED*10) 

#@onready
#var animations = $animations
@onready
var state_chart = $StateChart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(position)
	print(global_position)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var input_x: float = Input.get_axis("left","right")	
	
	pid_target.position.x = (input_x * 40)


	var error := Vector2.ZERO
	error = pid_target.global_position - global_position
	
	# when to apply correction, including drag
	if error.length_squared() != 0:# or player.is_on_floor:
		var correction: Vector2 = pid.update(error, delta) * 0.1
		self.apply_central_impulse(correction) 
	
	
