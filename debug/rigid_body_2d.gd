extends RigidBody2D

@export var pvec := Vector3(1.0, 0.1, 0.1)
var pid_angle = PIDFloat.new(pvec.x, pvec.y, pvec.z,
				 -45, 45, 999, PIDFloat.DerivativeMeasurement.VELOCITY)

@onready var button_pressed := false
@onready var lbl_target: Label = $"../lbl_target"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	
	var input_x: float = Input.get_axis("left","right")
	
	# update pid controller
	pid_angle._p = pvec.x
	pid_angle._i = pvec.y
	pid_angle._d = pvec.z
	
	# apply pid	
	var current_angle = self.rotation_degrees 
	var target_angle = input_x * 45 	
	lbl_target.text = "target angle: " + str(target_angle)
	
	var pid_output: float = pid_angle.update_angle(delta, current_angle, target_angle)
	self.apply_torque(pid_output * 100 * 100)
	#self.apply_torque_impulse(pid_output * 100)
	#self.apply_torque_impulse(100)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if button_pressed:
		state.angular_velocity = 0
		state.linear_velocity = Vector2.ZERO
		var tm := state.transform
		var cur_pos = state.transform.get_origin()
		var cur_rot = state.transform.get_rotation()
		var cur_scale = state.transform.get_scale()
		var new_tm : Transform2D = Transform2D(deg_to_rad(35), cur_scale, 0, cur_pos)
		
		#state.transform = state.transform.rotated(-self.rotation)
		state.transform = new_tm
		button_pressed = false
		#self.rotation_degrees = 35.0
		#self.linear_velocity = Vector2.ZERO
		#self.angular_velocity = 0.0

func _on_button_pressed() -> void:
	button_pressed = true
	
