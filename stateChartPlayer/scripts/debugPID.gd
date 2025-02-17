extends Control

@onready var chart: Control = $MarginContainer/HBoxContainer/Chart
@onready var info: Label = $MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/info

@export var max_points: int = 200  # Maximum points to keep in history
@export var graph_height: float = 50.0  # Vertical scaling factor
@export var time_step: float = 0.1  # Interval between updates

var pid_data: Dictionary = {
	"P": [],
	"I": [],
	"D": [],
	"target": [],
	"current": []
}

# Colors for visualization
var colors = {
	"P": Color.RED,
	"I": Color.GREEN,
	"D": Color.BLUE,
	"target": Color.WHITE,
	"current": Color.YELLOW
}

func _ready():
	chart.set_process(true)

func _process(delta):
	# Simulate getting PID values (replace with actual PID controller values)
	var p = randf_range(-1, 1)
	var i = randf_range(-0.5, 0.5)
	var d = randf_range(-0.2, 0.2)
	var target = 1.0
	var current = sin(Time.get_unix_time_from_system())  # Replace with real data
	
	update_graph(p, i, d, target, current)
	update_info(p, i, d, target, current)


func update_info(p: float, i: float, d: float, target: float, current: float):
	# update the label text
	info.text = "P: %.2f\nI: %.2f\nD: %.2f\nTarget: %.2f\nCurrent: %.2f" % [p, i, d, target, current]
	

func update_graph(p: float, i: float, d: float, target: float, current: float):
	# Store new values
	pid_data["P"].append(p)
	pid_data["I"].append(i)
	pid_data["D"].append(d)
	pid_data["target"].append(target)
	pid_data["current"].append(current)
	
	# Trim excess data
	for key in pid_data:
		if pid_data[key].size() > max_points:
			pid_data[key].pop_front()
	
	chart.queue_redraw()  # Request a redraw of the graph

func custom_draw():		
	var x_spacing = float(chart.size.x) / max_points  # Space between points
	var y_mid = chart.size.y / 2  # Midpoint of the graph
	
	for key in pid_data:
		var data = pid_data[key]
		var prev_point = Vector2(0, y_mid - (data[0] * graph_height)) if data.size() > 0 else Vector2()

		for i in range(1, data.size()):
			var x = i * x_spacing
			var y = y_mid - (data[i] * graph_height)
			var current_point = Vector2(x, y)
			
			chart.draw_line(prev_point, current_point, colors[key], 2.0)
			prev_point = current_point


# tell the chart to draw
func _on_chart_draw() -> void:
	custom_draw() # Replace with function body.
