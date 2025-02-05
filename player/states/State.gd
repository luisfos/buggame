class_name StateNode
extends Node

signal transitioned(state: StateNode, new_state_name: String)

func Enter():
	pass

func Exit():
	pass

func Update(delta: float):
	pass

func PhysicsUpdate(delta: float):
	pass
