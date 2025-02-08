extends Node

##########################################################
# The state machine runs each state's respective update functions
# states will change by either returning the name of the next state
# or by emitting a signal with the name of the state
##########################################################


@export var initial_state_name : String = ""
@export var debug_transition : bool = false
var current_state : StateNode = null
var states : Dictionary = {}


# we have a mix of either returning states and using change_state, or transition signals from
# https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-4/state-machines/src/player/states/move.gd
# https://github.com/Bitlytic/Strategy-GDScript/blob/master/Objects/Scripts/Enemy/enemy_state_machine.gd
# narrow this down to one method!!!

func init(player: Player) -> void:
	for child in get_children():
		if child is StateNode:
			child.player = player
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_transition)            

	if initial_state_name:
		on_state_transition(null, initial_state_name)
		


func on_state_transition(state: StateNode, new_state_name: String) -> void:	
	if debug_transition:
		if state:
			print("current state: ", state.name)
		else:
			print("current state: NULL")
		print("new state: ", new_state_name)
	# state should be self when used
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	# Clean up the previous state
	if current_state:
		current_state.exit()
	
	# Intialize the new state
	current_state = new_state
	new_state.enter()


# state functions return the next state to transition to if any

func process_frame(delta: float) -> void:
	if current_state:
		var new_state = current_state.process_frame(delta)
		if new_state:
			on_state_transition(current_state, new_state)

func process_physics(delta: float) -> void:
	if current_state:
		var new_state = current_state.process_physics(delta)
		if new_state:
			on_state_transition(current_state, new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		on_state_transition(current_state, new_state)

func process_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if current_state:
		var new_state = current_state.process_integrate_forces(state)
		if new_state:
			on_state_transition(current_state, new_state)
