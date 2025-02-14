extends RigidBody2D

# TODO
# create a PID debugger for input / output 
# see https://www.youtube.com/watch?v=6EcxGh1fyMw&list=LL&index=1&pp=gAQBiAQB
# limit jumping only while grounded
# add faster fall speed?
# how to limit our speed 

# all player external parms in CAPS
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var MOVE_SPEED: float = 50.0
@export var JUMP_SPEED: float = 1000.0
@export var ACCEL_TIME := 0.1
const TERMINAL_SPEED := 1000.0

# maybe references should be prefixed?
@onready var rayAnchor : Node2D  = $anchor
@onready var rayL : RayCast2D  = $anchor/rayL
@onready var rayC : RayCast2D  = $anchor/rayC
@onready var rayR : RayCast2D  = $anchor/rayR
@onready var pid_target : Node2D = $PID_target
@onready
var _state_chart = $StateChart

# persisting variables, maybe prefix with _?
var is_on_floor : bool = false
var current_state : String = ""
var pid := PID_2D.new(1.0, 0.0, 0.1, TERMINAL_SPEED*10) 

#@onready
#var animations = $animations

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.lock_rotation = true


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
		var correction: Vector2 = pid.update(error, delta) 
		self.apply_central_impulse(correction) 

		
func update_is_on_floor() -> bool:	
	rayAnchor.rotation = -rotation	
	var hitL: bool = rayL.is_colliding()
	var hitC: bool = rayC.is_colliding()
	var hitR: bool = rayR.is_colliding()
	is_on_floor = maxi(maxi(hitL, hitR), hitC)
	return is_on_floor
	
	

func _on_movement_state_physics_processing(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		self.apply_central_impulse(Vector2(0,-JUMP_SPEED))		
		_state_chart.send_event("jump")
