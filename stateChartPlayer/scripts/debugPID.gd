extends Control

@onready var chart: Control = $MarginContainer/HBoxContainer/Chart
@onready var info: Label = $MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/info

@onready var label_min_y: Label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/min_y
@onready var label_max_y: Label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/max_y
@onready var title: Label = $MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/Title

@export var node: Node2D = null  # Node to monitor
@export var property: String = ""  # name of the PID property belonging to node
@export var max_points: int = 200  # Maximum points to keep in history
@export var data_bounds: float = 1.0  # Vertical scaling factor
@export var time_step: float = 0.1  # Interval between updates

var pid_data: Dictionary = {
	#"P": [],
	#"I": [],
	#"D": [],
	"target": [],
	"current": [],
	"output": [],
}

# Colors for visualization
var colors = {
	#"P": Color.RED,
	#"I": Color.GREEN,
	#"D": Color.BLUE,
	"target": Color.WHITE,
	"current": Color.YELLOW,
	"output": Color.PURPLE,	
}

func _ready():
	chart.set_process(true)
	# set label text to data bounds
	label_min_y.text = str(-data_bounds)
	label_max_y.text = str(data_bounds)
	title.text = "PID: " + property


func _process(delta):
	# Simulate getting PID values (replace with actual PID controller values)
	var p: float
	var i: float
	var d: float
	var target: float
	var current: float
	var output: float
	if node and property:
		var pid = node.get(property)
		p = pid._p
		i = pid._i
		d = pid._d
		current = pid.value_last
		target = current + pid.error_last
		output = pid.result_last
	else:
		# Simulate random PID values		
		p = randf_range(-1, 1)
		i = randf_range(-0.5, 0.5)
		d = randf_range(-0.2, 0.2)
		target = 1.0
		current = sin(Time.get_unix_time_from_system())  # Replace with real data
	
	update_graph(p, i, d, target, current, output)
	update_info(p, i, d, target, current, output)


func update_info(p: float, i: float, d: float, target: float, current: float, output: float):
	# update the label text
	info.text = "P: %.2f\nI: %.2f\nD: %.2f\nTarget: %.2f\nCurrent: %.2f\nOutput: %.2f\nError: %.2f" % [p, i, d, target, current, output, target-current]
	

func update_graph(p: float, i: float, d: float, target: float, current: float, output: float):
	# Store new values
	#pid_data["P"].append(p)
	#pid_data["I"].append(i)
	#pid_data["D"].append(d)
	pid_data["target"].append(target)
	pid_data["current"].append(current)
	pid_data["output"].append(output)
	
	# Trim excess data
	for key in pid_data:
		if pid_data[key].size() > max_points:
			pid_data[key].pop_front()
	
	chart.queue_redraw()  # Request a redraw of the graph

func custom_draw():		
	var x_spacing = float(chart.size.x) / max_points  # Space between points
	# var y_mid = chart.size.y / 2  # Midpoint of the graph
	
	var pad = 1.1
	# all values should be normalized 0-1, so we can scale them to the graph height
	for key in pid_data:
		var data = pid_data[key]
		# var prev_point = Vector2(0, y_mid - (data[0] * graph_height)) if data.size() > 0 else Vector2()
		var prev_point = Vector2(0, remap(data[0], -data_bounds*pad, data_bounds*pad, 0, chart.size.y)) if data.size() > 0 else Vector2()

		for i in range(1, data.size()):
			var x = i * x_spacing
			# var y = y_mid - (data[i] * graph_height)
			var y = remap(data[i],-data_bounds*pad,data_bounds*pad,0,chart.size.y)
			var current_point = Vector2(x, y)
			
			chart.draw_line(prev_point, current_point, colors[key], 2.0)
			prev_point = current_point


# tell the chart to draw
func _on_chart_draw() -> void:
	custom_draw() # Replace with function body.
