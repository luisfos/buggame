extends Node

@export var initial_state : StateNode

var current_state : StateNode = null
var states : Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is StateNode:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)            

	if initial_state:
		current_state = initial_state
		current_state.Enter()

func _process(delta: float) -> void:
	if current_state != null:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.PhysicsUpdate(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return

	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
