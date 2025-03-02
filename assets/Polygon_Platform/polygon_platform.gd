@tool
extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		var coll := CollisionPolygon2D.new()
		coll.one_way_collision = true
		coll.polygon = $Polygon2D.polygon
		coll.transform = $Polygon2D.transform
		add_child(coll)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
