extends StaticBody2D

@export var size: Vector2 = Vector2(100, 100)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var dragging = false
var offset = Vector2()

func _process(delta: float) -> void:
	if dragging:
		if Input.is_action_just_pressed("shoot"):
			offset = self.global_position - get_global_mouse_position()
		if Input.is_action_pressed("shoot"):
			var mouse_pos = get_global_mouse_position()
			self.global_position = mouse_pos + offset


func _on_mouse_entered() -> void:	
	if not dragging:
		dragging = true


func _on_mouse_exited() -> void:
	if dragging:
		dragging = false
