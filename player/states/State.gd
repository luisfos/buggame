class_name StateNode
extends Node

#####################################
# This is the base state
# Each state will inherit from this
#####################################

const NO_CHANGE : String = ""
var player : Player

signal transitioned(state: StateNode, new_state_name: String)

func enter() -> void:
	pass

func exit() -> void:
	pass

func process_input(event: InputEvent) -> String:
	return NO_CHANGE

func process_frame(delta: float) -> String:
	return NO_CHANGE

func process_physics(delta: float) -> String:
	return NO_CHANGE

func process_integrate_forces(state: PhysicsDirectBodyState2D) -> String:
	return NO_CHANGE
