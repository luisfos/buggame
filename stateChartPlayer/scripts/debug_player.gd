extends Control

@onready var player: RigidBody2D = self.get_parent()

@onready var line_thrust: RayCast2D = $line_thrust
@onready var line_movement: RayCast2D = $line_movement

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	line_thrust.target_position = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var thrust: Vector2 = player.output_thrust_force
	# line_thrust.set_point_position(1, output_force)
	line_thrust.target_position = player.output_thrust_force
	line_movement.target_position = player.output_movement_force
