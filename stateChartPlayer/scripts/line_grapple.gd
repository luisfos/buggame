extends Line2D

@export var objA: PhysicsBody2D
@export var objB: PhysicsBody2D

@export var num_segments: int
@export var target_length_ratio: float

var bodies: Array = []
var is_created = false

var offsetA := Vector2.ZERO
var offsetB := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ensure size == 2		
	create_rope()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_created:
		queue_redraw()  # Forces redraw
		pass

func create_rope() -> void:
	# create number of rigidbody segements
	if self.points.size() != 2:
		printerr("Grapple must have exactly 2 points.")
	# create pin start & pin end
	var locA : Vector2 = self.points[0]
	var locB : Vector2 = self.points[1]

	# store offset relative to the object's transform	
	# this seems to do the inverse, maybe due to order?		
	offsetA = locA * objA.transform
	offsetB = locB * objB.transform		

	var previous_body = objA	
	var segment_length: float = (locB - locA).length() / num_segments	
	var segment_direction: Vector2 = (locB - locA) / num_segments
	var segment_transform : Transform2D = Transform2D(segment_direction.angle(), locA)
	# adjust segment direction to be in local space of objA	

	var shape = CircleShape2D.new()
	shape.radius = 5

	for i in range(num_segments):
		# make pin then make rigidbody sphere
		print("i this many times:", i)
		var joint = DampedSpringJoint2D.new()	
		joint.transform = segment_transform.translated_local(Vector2(i*segment_length, 0))	
		joint.rotate(-PI*.5)
		joint.length = segment_length
		joint.rest_length = segment_length * target_length_ratio		
		joint.stiffness = 64.0
		self.add_child(joint)
		joint.node_a = previous_body.get_path()

		if i < num_segments - 1:
			var body = RigidBody2D.new()		
			# body.freeze = true
			body.transform = segment_transform.translated_local(Vector2((i+1)*segment_length, 0))

			var colshape: CollisionShape2D = CollisionShape2D.new()
			colshape.shape = shape
			body.add_child(colshape)

			self.add_child(body)			
			bodies.append(body)

			previous_body = body
			# connect second object
			joint.node_b = body.get_path()
		else: # on last dont use body			
			joint.node_b = objB.get_path()		
		
	self.is_created = true

func reset_rope() -> void:
	self.points[0] = offsetA
	self.points[1] = offsetB

	for body in bodies:
		body.queue_free()
	bodies.clear()
	self.is_created = false
	
func _draw() -> void:	
	if is_created:
		# draw line from each pin point inside container
		var _pts = []
		var first_pos = offsetA * objA.transform.inverse()
		var last_pos = offsetB * objB.transform.inverse()
		
		_pts.append(first_pos)
		for body in bodies:
			_pts.append(body.global_position)		
		_pts.append(last_pos)		

		if _pts.size() > 4:
			self.points = catmull_rom_spline(_pts)
			# self.points = _pts
			# draw_polyline(_pts, Color.WHITE, 2.0)
	

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
