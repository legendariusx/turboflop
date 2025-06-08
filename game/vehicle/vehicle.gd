extends VehicleBody3D
class_name Vehicle

const MATERIAL_DARK_SMOKE = preload("res://assets/materials/DarkSmoke.tres")
const MATERIAL_GLOWING_SMOKE = preload("res://assets/materials/GlowingSmoke.tres")

@export_group("Car Behaviour")
@export var acceleration_force: float = 100.0
@export var brake_strength: float = 2.0
@export var brake_soft_strength: float = 0.5
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.4

@export_group("Car Components")
@export var material_car_opaque: StandardMaterial3D
@export var material_car_transparent: StandardMaterial3D
@export var wheel_fl: VehicleWheel3D
@export var wheel_fr: VehicleWheel3D
@export var wheel_bl: VehicleWheel3D
@export var wheel_br: VehicleWheel3D
@export var body_mesh: MeshInstance3D
@export var body_collider: CollisionShape3D

@onready var wheels: Array[VehicleWheel3D] = [wheel_fl, wheel_fr, wheel_bl, wheel_br]

# generic vehicle components
@onready var engine_sound: AudioStreamPlayer3D = $EngineSound
@onready var audio_listener: AudioListener3D = $AudioListener3D
@onready var speedometer: Label3D = $Speedometer
@onready var name_label: Label3D = $NameLabel
@onready var boost_timer: Timer = $BoostTimer

# particle systems
@onready var dark_particles_l: GPUParticles3D = $ExhaustParticles/DarkParticlesL
@onready var dark_particles_r: GPUParticles3D = $ExhaustParticles/DarkParticlesR
@onready var glowing_particles_l: GPUParticles3D = $ExhaustParticles/GlowingParticlesL
@onready var glowing_particles_r: GPUParticles3D = $ExhaustParticles/GlowingParticlesR
@onready var wheel_particles_bl: GPUParticles3D = $WheelParticles/WheelDustBL
@onready var wheel_particles_br: GPUParticles3D = $WheelParticles/WheelDustBR
@onready var exhaust_particles: Array[GPUParticles3D] = [dark_particles_l, dark_particles_r, glowing_particles_l, glowing_particles_r]

var owner_identity: PackedByteArray
var owner_name: String
var is_current_user: bool = true

var _is_input_enabled: bool = false
var _is_steering : bool
var _is_accelerating : bool
var _is_braking : bool
var _is_update_disabled: bool = false

var _speed : float
var _boost_multiplier: float = 1

func set_owner_data(u_owner_identity: PackedByteArray, u_owner_name: String):
	owner_identity = u_owner_identity
	is_current_user = u_owner_identity == GameState.identity or not SpacetimeDB.is_connected_db()
	owner_name = u_owner_name
	
func booster_entered(boost_multiplier: float, boost_duration: float):
	boost_timer.start(boost_duration)
	_boost_multiplier = boost_multiplier
	
	_set_particles(true)

func on_boost_timer_timeout() -> void:
	_boost_multiplier = 1.0
	_set_particles(false)
	
func enable_input() -> void:
	_is_input_enabled = true
	
func disable_input() -> void:
	_is_input_enabled = false
	
	steering = 0.0
	brake = 0.0
	engine_force = 0.0

func _ready():
	if not is_current_user:
		body_collider.disabled = true
		name_label.text = owner_name
		# FIXME: ugly fix for cars bugging around when tabbed out (#14)
		freeze = true
		audio_listener.queue_free()
		speedometer.queue_free()
	else:
		name_label.visible = false
		
	GameState.visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed(GameState.visibility)
	
	UserState.update.connect(_on_user_updated)
	
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)

func _physics_process(delta: float) -> void:
	var desired_engine_pitch = 0.05 + linear_velocity.length() / (acceleration_force * 0.5)
	engine_sound.pitch_scale = lerpf(engine_sound.pitch_scale, desired_engine_pitch, 0.2)
	
	_update_particle_systems()
	
	if not is_current_user or _is_update_disabled: return
	
	UserData.set_user_data(global_position, global_rotation, linear_velocity, angular_velocity, true, GameState.track_id)
	
	# get current speed
	#_speed = linear_velocity.dot(transform.basis.z)
	_speed = (quaternion.inverse() * linear_velocity).length()
	speedometer.text = str(abs(int(_speed * 3.6)))
	
	if not _is_input_enabled:
		return
	
	# get input
	var steer_axis = Input.get_axis(&"turn_right", &"turn_left")
	var force_axis = Input.get_axis(&"reverse", &"accelerate")
	var brake_strength = Input.get_action_strength(&"brake")
	
	# set input flags
	_is_steering = not is_zero_approx(steer_axis)
	_is_accelerating = not is_zero_approx(force_axis)
	_is_braking = Input.is_action_pressed(&"brake")
	
	# set steering angle
	steering = move_toward(steering, steer_axis * steer_limit, delta * steer_speed)
	
	# set brake
	if _is_braking:
		brake = brake_strength * brake_strength
	# TODO: is this needed? currently stops the car
	elif not _is_accelerating and false:
		brake = brake_soft_strength
	else:
		brake = 0.0
	
	# set engine force
	if _is_accelerating and not _is_braking:
		var force = force_axis * acceleration_force
		if abs(_speed) < 5.0 and not is_zero_approx(_speed):
			engine_force = clampf(force * 5.0 / abs(_speed), -acceleration_force, acceleration_force)
		else:
			engine_force = force
		
		# add booster multiplier
		engine_force *= _boost_multiplier
	else:
		engine_force = 0.0
	
func _update_particle_systems():
	var t = clampf(_speed / 6.0, 0.1, 1.0)
	
	for particle_system in exhaust_particles:
		particle_system.amount_ratio = t
		particle_system.process_material.initial_velocity_min = linear_velocity.dot(transform.basis.z) * -1
		particle_system.process_material.initial_velocity_max = linear_velocity.dot(transform.basis.z) * -1
	
	# FIXME: check if the contacting body is the terrain
	wheel_particles_bl.emitting = wheel_bl.get_contact_body() != null
	wheel_particles_br.emitting = wheel_br.get_contact_body() != null

func _set_particles(is_boosting: bool):
	dark_particles_l.emitting = not is_boosting
	dark_particles_r.emitting = not is_boosting
	glowing_particles_l.emitting = is_boosting
	glowing_particles_r.emitting = is_boosting

func _on_visibility_changed(u_visibility: Enum.Visibility):
	if is_current_user: return
	
	if u_visibility == Enum.Visibility.NONE:
		visible = false
		return
	
	var new_material = material_car_opaque if u_visibility == Enum.Visibility.OPAQUE else material_car_transparent
	body_mesh.material_override = new_material
	for wheel in wheels:
		wheel.get_node("Mesh").material_override = new_material
		
	visible = true
	
func _on_user_updated(row: User):
	if row.identity == owner_identity:
		$NameLabel.text = row.name
		owner_name = row.name
		
func _on_window_focus_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, false))
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), -80, 0, 0.5)

func _on_window_focus_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), 0, -80, 0.5)
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, true))
