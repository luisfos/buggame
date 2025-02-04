extends CanvasLayer



@onready var lbl_parms: Label = $PanelContainer/MarginContainer/VBoxContainer/lbl_parms

@export var node01: Node2D
@export var properties: Array[String] = []
#@export var multiple: Array[Node2D] = []



func get_property_string(node: Node, property_name: String) -> String:
	# Use the get() method to retrieve the property's value.
	var value = node.get(property_name)
	# Format the output string.
	return "%s : %s" % [property_name, str(value)]


func _ready() -> void:
	lbl_parms.text = ""	

func _process(delta: float) -> void:    
	lbl_parms.text = ""	
	for property in properties:
		lbl_parms.text += get_property_string(node01, property) + "\n"  
		
	

	
