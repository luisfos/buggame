extends PanelContainer

@export var player: PlatformerController2D
@onready var margcon = $HBoxContainer/MarginContainer
@onready var max_speed = $HBoxContainer/MarginContainer/VBoxContainer/MaxSpeed
@onready var ttr_max_speed = $HBoxContainer/MarginContainer/VBoxContainer/TTRMaxSpeed
@onready var ttr_zero_speed = $HBoxContainer/MarginContainer/VBoxContainer/TTRZeroSpeed
@onready var d_snap = $HBoxContainer/MarginContainer/VBoxContainer/DSnap
@onready var r_modifier = $HBoxContainer/MarginContainer/VBoxContainer/RModifier
@onready var jump_height = $HBoxContainer/MarginContainer/VBoxContainer/JumpHeight
@onready var jumps = $HBoxContainer/MarginContainer/VBoxContainer/Jumps
@onready var gravity = $HBoxContainer/MarginContainer/VBoxContainer/Gravity
@onready var terminal_vel = $HBoxContainer/MarginContainer/VBoxContainer/TerminalVel
@onready var descending_grav_factor = $HBoxContainer/MarginContainer/VBoxContainer/DescendingGravFactor
@onready var var_jump_height = $HBoxContainer/MarginContainer/VBoxContainer/VarJumpHeight
@onready var coyote_time = $HBoxContainer/MarginContainer/VBoxContainer/CoyoteTime
@onready var jump_buffering = $HBoxContainer/MarginContainer/VBoxContainer/JumpBuffering
@onready var wall_jump = $"HBoxContainer/MarginContainer/VBoxContainer/Wall Jump"
@onready var input_pause = $HBoxContainer/MarginContainer/VBoxContainer/InputPause
@onready var angle = $HBoxContainer/MarginContainer/VBoxContainer/Angle
@onready var sliding = $HBoxContainer/MarginContainer/VBoxContainer/Sliding
@onready var latching = $HBoxContainer/MarginContainer/VBoxContainer/Latching
@onready var latching_mod = $HBoxContainer/MarginContainer/VBoxContainer/LatchingMod
@onready var dash_type = $HBoxContainer/MarginContainer/VBoxContainer/DashType
@onready var label_14 = $HBoxContainer/MarginContainer/VBoxContainer/label14
@onready var dash_cancel = $HBoxContainer/MarginContainer/VBoxContainer/DashCancel
@onready var dash_length = $"HBoxContainer/MarginContainer/VBoxContainer/Dash Length"
@onready var corner_cutting = $HBoxContainer/MarginContainer/VBoxContainer/CornerCutting
@onready var cor_amount = $HBoxContainer/MarginContainer/VBoxContainer/CorAmount
@onready var show_casts = $HBoxContainer/MarginContainer/VBoxContainer/showCasts
@onready var crouching = $HBoxContainer/MarginContainer/VBoxContainer/Crouching
@onready var can_roll = $"HBoxContainer/MarginContainer/VBoxContainer/Can Roll"
@onready var roll_length = $"HBoxContainer/MarginContainer/VBoxContainer/Roll Length"
@onready var ground_pounding = $HBoxContainer/MarginContainer/VBoxContainer/GroundPounding
@onready var gpp_time = $HBoxContainer/MarginContainer/VBoxContainer/GPPTime
@onready var gpc = $HBoxContainer/MarginContainer/VBoxContainer/GPC
@onready var tab = $MarginContainerOffset/Tab
@onready var v_scroll_bar = $HBoxContainer/VScrollBar
@onready var dashes = $HBoxContainer/MarginContainer/VBoxContainer/Dashes

var n_colliding:= Color(0.525, 1, 1, 0.498)
var collding:= Color(1, 0.077, 0.142, 0.596)
var showCasts: bool = false

@export var lcast: RayCast2D
@export var mcast: RayCast2D
@export var rcast: RayCast2D

var lcastS: Node
var mcastS: Node
var rcastS: Node

var opened: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	lcastS = lcast.get_child(0)
	mcastS = mcast.get_child(0)
	rcastS = rcast.get_child(0)
	assert(lcast!=null)	
	

func _on_update_settings_pressed():
	_updateSettings()
	
func _input(event):
	if event is InputEventKey:
		_updateSettings()
	if event is InputEventMouse:
		pass
		
		
func _process(delta):
	margcon.position.y = -v_scroll_bar.value
	
	if lcast.is_colliding():
		lcastS.color = collding
	else:
		lcastS.color = n_colliding
		
	if mcast.is_colliding():
		mcastS.color = collding
	else:
		mcastS.color = n_colliding
		
	if rcast.is_colliding():
		rcastS.color = collding
	else:
		rcastS.color = n_colliding
		
	if player.jumpCount < 0:
		player.jumpCount = 0
	$"debugText".text = ("x velocity: " + str(round(player.velocity.x)) + 
	"\ny velocity: " + str(round(-player.velocity.y)) + "\njumps: " +
	str(player.jumpCount))

		
func _on_tab_pressed():
	opened = !opened
	if opened:
		tab.text = ">"
		position.x -= 250
	else:
		tab.text = "<"
		position.x += 250

		
func _updateSettings():
	player.maxSpeed = max_speed.value
	player.timeToReachMaxSpeed = ttr_max_speed.value
	player.timeToReachZeroSpeed = ttr_zero_speed.value
	player.directionalSnap = d_snap.button_pressed
	player.runningModifier = r_modifier.button_pressed
	
	player.jumpHeight = jump_height.value
	player.jumps = jumps.value
	player.gravityScale = gravity.value
	player.terminalVelocity = terminal_vel.value
	player.descendingGravityFactor = descending_grav_factor.value
	player.shortHopAkaVariableJumpHeight = var_jump_height.button_pressed
	player.coyoteTime = coyote_time.value
	player.jumpBuffering = jump_buffering.value
	
	player.wallJump = wall_jump.button_pressed
	player.inputPauseAfterWallJump = input_pause.value
	player.wallKickAngle = angle.value
	player.wallSliding = sliding.value
	player.wallLatching = latching.button_pressed
	player.wallLatchingModifer = latching_mod.button_pressed
	
	player.dashType = dash_type.selected
	player.dashes = dashes.value
	player.dashCancel = dash_cancel.button_pressed
	player.dashLength = dash_length.value
	player.cornerCutting = corner_cutting.button_pressed
	player.correctionAmount = cor_amount.value
	
	player.crouch = crouching.button_pressed
	player.canRoll = can_roll.button_pressed
	player.rollLength = roll_length.value
	player.groundPound = ground_pounding.button_pressed
	player.groundPoundPause = gpp_time.value
	player.upToCancel = gpc.button_pressed
	
	showCasts = show_casts.button_pressed
	
	if showCasts:
		lcastS.show()
		mcastS.show()
		rcastS.show()
	else:
		lcastS.hide()
		mcastS.hide()
		rcastS.hide()
		
	
	player._updateData()
		


func _on_dash_type_value_changed(value):
	if dash_type.value == 0:
		dash_type.prefix = "none"
	if dash_type.value == 1:
		dash_type.prefix = "horizontal"
	if dash_type.value == 2:
		dash_type.prefix = "vertical"
	if dash_type.value == 3:
		dash_type.prefix = "4 Way"
	if dash_type.value == 4:
		dash_type.prefix = "8 Way"
			


func _on_max_speed_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_ttr_max_speed_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_ttr_zero_speed_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_d_snap_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_r_modifier_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_jump_height_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_jumps_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_gravity_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_terminal_vel_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_descending_grav_factor_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_var_jump_height_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_coyote_time_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_jump_buffering_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_wall_jump_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_input_pause_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_angle_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_sliding_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_latching_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_latching_mod_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_dash_type_item_selected(index):
	_updateSettings() # Replace with function body.


func _on_dashes_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_dash_cancel_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_dash_length_value_changed(value):
	_updateSettings()

func _on_corner_cutting_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_cor_amount_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_show_casts_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_crouching_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_can_roll_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_roll_length_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_ground_pounding_toggled(toggled_on):
	_updateSettings() # Replace with function body.


func _on_gpp_time_value_changed(value):
	_updateSettings() # Replace with function body.


func _on_gpc_toggled(toggled_on):
	_updateSettings() # Replace with function body.
