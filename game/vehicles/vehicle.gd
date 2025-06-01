extends VehicleBody3D
class_name Vehicle

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0
const BRAKE_SOFT_STRENGTH = 0.5
const MATERIAL_CAR_OPAQUE = preload("res://vehicles/car.tres")
const MATERIAL_CAR_TRANSPARENT = preload("res://vehicles/car_transparent.tres")

@onready var mesh: MeshInstance3D = $Mesh

var owner_identity: PackedByteArray
var owner_name: String
var is_current_user: bool = true
var is_input_enabled: bool = false

var _is_steering : bool
var _is_accelerating : bool
var _is_braking : bool
var _is_update_disabled: bool = false

var _boost_finish_time: int = 0
var _boost_multiplier: float = 1

var _speed : float

@export var acceleration_force := 100.0
@export var wheels: Array[VehicleWheel3D]

@onready var audio_listener: AudioListener3D = $AudioListener3D
@onready var speedometer: Label3D = $Speedometer

func set_owner_data(u_owner_identity: PackedByteArray, u_owner_name: String):
	owner_identity = u_owner_identity
	is_current_user = u_owner_identity == GameState.identity or not SpacetimeDB.is_connected_db()
	owner_name = u_owner_name
	
func booster_entered(boost_multiplier: float, boost_duration: float):
	_boost_finish_time = Time.get_ticks_msec() + (boost_duration * 1000.0)
	_boost_multiplier = boost_multiplier

func _ready():
	if not is_current_user:
		$Collider.disabled = true
		$NameLabel.text = owner_name
		# FIXME: ugly fix for cars bugging around when tabbed out (#14)
		freeze = true
		audio_listener.queue_free()
		speedometer.queue_free()
	else:
		$NameLabel.visible = false
		
	GameState.visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed(GameState.visibility)
	
	UserState.update.connect(_on_user_updated)

func _physics_process(delta: float) -> void:
	var desired_engine_pitch = 0.05 + linear_velocity.length() / (acceleration_force * 0.5)
	$EngineSound.pitch_scale = lerpf($EngineSound.pitch_scale, desired_engine_pitch, 0.2)
	
	if not is_current_user or _is_update_disabled: return
	
	UserData.set_user_data(global_position, global_rotation, linear_velocity, angular_velocity, true, GameState.track_id)
	
	# check if boost has finished
	if Time.get_ticks_msec() > _boost_finish_time:
		_boost_multiplier = 1.0
	
	# get current speed
	_speed = linear_velocity.dot(transform.basis.z)
	speedometer.text = str(abs(int(_speed * 15)))
	
	# get input
	var steer_axis = Input.get_axis(&"turn_right", &"turn_left")
	var force_axis = Input.get_axis(&"reverse", &"accelerate")
	var brake_strength = Input.get_action_strength(&"brake")
	
	# set input flags
	_is_steering = not is_zero_approx(steer_axis)
	_is_accelerating = not is_zero_approx(force_axis)
	_is_braking = Input.is_action_pressed(&"brake")
	
	# set steering angle
	steering = move_toward(steering, steer_axis * STEER_LIMIT, delta * STEER_SPEED)
	
	# set brake
	if _is_braking:
		brake = brake_strength * BRAKE_STRENGTH
	# TODO: is this needed? currently stops the car
	elif not _is_accelerating and false:
		brake = BRAKE_SOFT_STRENGTH
	else:
		brake = 0.0
	
	# set engine force
	if _is_accelerating and not _is_braking:
		var force = force_axis * acceleration_force
		if abs(_speed) < 5.0 and not is_zero_approx(_speed):
			engine_force = clampf(force * 5.0 / abs(_speed), -100.0, 100.0)
		else:
			engine_force = force
		
		# add booster multiplier
		engine_force *= _boost_multiplier
	else:
		engine_force = 0.0
	
	# FIXME: ugly way to reset inputs if input is disabled
	if not is_input_enabled:
		engine_force = 0.0
		steering = 0.0
		brake = 0.0

func _on_visibility_changed(u_visibility: Enum.Visibility):
	if is_current_user: return
	
	if u_visibility == Enum.Visibility.NONE:
		visible = false
		return
	
	var new_material = MATERIAL_CAR_OPAQUE if u_visibility == Enum.Visibility.OPAQUE else MATERIAL_CAR_TRANSPARENT
	mesh.material_override = new_material
	for wheel in wheels:
		wheel.get_node("Mesh").material_override = new_material
		
	visible = true
	
func _on_user_updated(row: User):
	if row.identity == owner_identity:
		$NameLabel.text = row.name
		owner_name = row.name
		
