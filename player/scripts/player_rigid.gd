class_name Player
extends RigidBody2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var MOVE_SPEED: float = 100.0
const TERMINAL_SPEED := 1000.0


@onready var rayAnchor : Node2D  = $anchor
@onready var rayL : RayCast2D  = $anchor/rayL
@onready var rayC : RayCast2D  = $anchor/rayC
@onready var rayR : RayCast2D  = $anchor/rayR



var is_on_floor : bool = false
var current_state : String = ""
var pid := PID_2D.new(1.0, 0.0, 0.1, TERMINAL_SPEED*10) 

#@onready
#var animations = $animations
@onready
var state_machine = $state_machine

func _ready() -> void:
	# Initialize the state machine, passing a reference of the player to the states,
	# that way they can move and react accordingly
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	update_is_on_floor()
	state_machine.process_physics(delta)

	# we cannot edit linear velocity directly if we are using a rigid body
	# linear_velocity.y = clampf(linear_velocity.y, -TERMINAL_SPEED, TERMINAL_SPEED)
	# linear_velocity.x = clampf(linear_velocity.x, -TERMINAL_SPEED, TERMINAL_SPEED)	

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
	current_state = state_machine.current_state.name

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state_machine.process_integrate_forces(state)
	
func update_is_on_floor() -> bool:
	# rayL.rotation = -rotation
	# rayC.rotation = -rotation
	# rayR.rotation = -rotation
	rayAnchor.rotation = -rotation	

	var hitL: bool = rayL.is_colliding()
	var hitC: bool = rayC.is_colliding()
	var hitR: bool = rayR.is_colliding()

	is_on_floor = maxi(maxi(hitL, hitR), hitC)
	return is_on_floor
