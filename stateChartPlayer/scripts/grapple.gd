extends Node2D

# @onready var spring: DampedSpringJoint2D = $DampedSpringJoint2D
# @onready var line_2d: Line2D = $Line2D
# var rope_points = []

@onready var objStatic: StaticBody2D = $StaticBody2D
@onready var objDynamic: RigidBody2D = $RigidBody2D
#@onready var rope_grp: Node2D = $rope
@onready var container: Node2D = $container
@onready var _seg: RigidBody2D = $_seg
@onready var _pin: PinJoint2D = $_pin
@onready var _shape: CollisionShape2D = $_shape


# next make a normal pinjoint + segment system, fuck this damped spring node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	create_polyline(3, objStatic, objDynamic, objStatic.global_position, objDynamic.global_position)
	

func _process(delta: float) -> void:
	pass
	
	# queue_redraw()  # Forces redraw

func _draw():
	pass
	# if rope_points.size() > 1:
	# 	draw_polyline(rope_points, Color.WHITE, 2.0)
		

# function to initialize the rope
func create_polyline(segments: int, pinA: PhysicsBody2D, pinB: PhysicsBody2D, posA: Vector2, posB: Vector2) -> void:
	# create number of rigidbody segements
	# create pin start & pin end
	
	# remove all children from rope_grp
	# rope_grp.clear()
	for child in container.get_children():
		container.remove_child(child)	

	var previous_body = pinA	
	var segment_length: float = (posB - posA).length() / segments

	# var collision = CollisionShape2D.new()
	# collision.shape = SegmentShape2D.new()	
	# collision.shape.a = Vector2.ZERO
	# collision.shape.b = Vector2(segment_length, 0) # pos x axis is 0 angle
	print(segment_length)

	for i in range(segments):
		# var segment = RigidBody2D.new()

		var segment: RigidBody2D = _seg.duplicate()		
		var colshape: CollisionShape2D = CollisionShape2D.new()
		var new_shape = SegmentShape2D.new()
		new_shape.a = Vector2.ZERO
		new_shape.b = Vector2(segment_length, 0)
		colshape.shape = new_shape
		segment.add_child(colshape)
		# var shape: CollisionShape2D = _shape.duplicate()
		# print(shape)
		# shape.shape.b.x = segment_length# = Vector2(segment_length, 0)
		# segment.add_child(shape)		
		# segment.set_process(true)
		
		# segment.get_child(0).shape.b = Vector2(segment_length, 0)
		segment.position.x = segment_length * i
		
		container.add_child(segment)		
		
		var pin_joint: PinJoint2D = _pin.duplicate()		
		pin_joint.position.x = segment_length * i
		pin_joint.node_a = previous_body.get_path()
		pin_joint.node_b = segment.get_path()
		container.add_child(pin_joint)

		segment.process_mode = Node.PROCESS_MODE_INHERIT
		colshape.process_mode = Node.PROCESS_MODE_INHERIT
		pin_joint.process_mode = Node.PROCESS_MODE_INHERIT

		previous_body = segment

	# var end_pin_joint = PinJoint2D.new()
	var end_pin_joint: PinJoint2D = _pin.duplicate()
	end_pin_joint.position.x = segment_length * segments
	end_pin_joint.node_a = previous_body.get_path()
	end_pin_joint.node_b = pinB.get_path()
	end_pin_joint.process_mode = Node.PROCESS_MODE_INHERIT
	container.add_child(end_pin_joint)

	container.position = posA
	container.rotation = (posB - posA).angle()


func catmull_rom_spline(_points: Array, resolution: int = 10, extrapolate_end_points = true) -> PackedVector2Array:
	var points = _points.duplicate()
	if extrapolate_end_points:
		points.insert(0, points[0] - (points[1] - points[0]))
		points.append(points[-1] + (points[-1] - points[-2]))

	var smooth_points := PackedVector2Array()
	if points.size() < 4:
		return points

	for i in range(1, points.size() - 2):
		var p0 = points[i - 1]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[i + 2]

		for t in range(0, resolution):
			var tt = t / float(resolution)
			var tt2 = tt * tt
			var tt3 = tt2 * tt

			var q = (
			0.5
			* (
			  (2.0 * p1)
			  + (-p0 + p2) * tt
			  + (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * tt2
			  + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * tt3
			)
			)
			
			smooth_points.append(q)

	return smooth_points
