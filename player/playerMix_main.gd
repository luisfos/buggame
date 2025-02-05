extends Node2D

enum Method {
	movement,
	pinball,
}

var initial_method : Method = Method.movement



func _physics_process(delta: float) -> void:
	# runs every physics tick, less often than process	
	pass
