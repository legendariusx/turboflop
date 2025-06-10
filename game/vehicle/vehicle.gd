extends VehicleBody3D
class_name Vehicle

const MATERIAL_DARK_SMOKE = preload("res://assets/materials/DarkSmoke.tres")
const MATERIAL_GLOWING_SMOKE = preload("res://assets/materials/GlowingSmoke.tres")

@export var car_id: int = -1
@export var car_name: String
@export var car_thumbnail: Texture2D

@export_group("Car Behaviour")
@export var acceleration_force: float = 1000.0
@export var max_backwards_speed: float = 8.0
@export var brake_force: float = 5.0
@export var brake_soft_strength: float = 0.5
@export var steer_speed: float = 1.5
@export var steer_limit: float = 0.4
@export var boost_increment: float = 1.0
@export var boost_duration: float = 1.5

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
@onready var speedometer: Label3D = $UI/Speedometer
@onready var boost_sprite: Sprite3D = $UI/BoostSprite
@onready var name_label: Label3D = $NameLabel
@onready var boost_timer: Timer = $BoostTimer
@onready var fpv_marker: Marker3D = $FPVMarker

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

var _is_steering : bool
var _is_accelerating : bool
var _is_braking : bool
var _is_update_disabled: bool = false
var _has_boosted: bool = false

var _speed : float
var _boost_multiplier: float = 1

func set_owner_data(u_owner_identity: PackedByteArray, u_owner_name: String):
	owner_identity = u_owner_identity
	is_current_user = u_owner_identity == GameState.identity or not SpacetimeDB.is_connected_db()
	owner_name = u_owner_name
	
func booster_entered(u_boost_increment: float, u_boost_duration: float):
	boost_timer.start(u_boost_duration)
	_boost_multiplier += u_boost_increment
	
	_set_particles(true)

func on_boost_timer_timeout() -> void:
	_boost_multiplier = 1.0
	_set_particles(false)
	
func _on_input_enabled_changed(u_input_enabled: bool) -> void:
	if not u_input_enabled:
		steering = 0.0
		brake = 0.0
		engine_force = 0.0

func _ready():
	assert(car_id != -1, "vehicle_id needs to be set")	
	
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
	
	GameState.input_enabled_changed.connect(_on_input_enabled_changed)
	_on_input_enabled_changed(GameState.input_enabled)
	
	UserState.update.connect(_on_user_updated)
	
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)

func _physics_process(delta: float) -> void:
	var desired_engine_pitch = 0.05 + linear_velocity.length() / (acceleration_force * 0.1 * 0.5)
	engine_sound.pitch_scale = lerpf(engine_sound.pitch_scale, desired_engine_pitch, 0.2)
	
	_update_particle_systems()
	
	if not is_current_user or _is_update_disabled: return
	UserData.set_user_data(global_position, global_rotation, linear_velocity, angular_velocity, true, GameState.track_id, car_id)
	
	_speed = (quaternion.inverse() * linear_velocity).length()
	speedometer.text = str(abs(int(_speed * 3.6)))
	
	if not GameState.input_enabled:
		return
	
	# get input
	var steer_axis = Input.get_axis(&"turn_right", &"turn_left")
	var force_axis = Input.get_axis(&"reverse", &"accelerate")
	
	# set input flags
	_is_steering = not is_zero_approx(steer_axis)
	_is_accelerating = not is_zero_approx(force_axis)
	var _linear_speed = linear_velocity.dot(transform.basis.z)
	var _is_reversing = _linear_speed < 0 or abs(_linear_speed) < 0.5
	_is_braking = force_axis < 0 and not _is_reversing
	
	# set steering angle
	steering = move_toward(steering, steer_axis * steer_limit, delta * steer_speed)
	
	# set brake
	if _is_braking and not _is_reversing:
		brake = brake_force
		engine_force = 0.0
	elif not _is_braking and not _is_accelerating:
		brake = brake_soft_strength
	else:
		brake = 0.0
	
	# set engine force
	if _is_accelerating and not _is_braking:
		if force_axis < 0 and _speed > max_backwards_speed and _is_reversing:
			engine_force = 0.0
		else:
			engine_force = force_axis * acceleration_force * _boost_multiplier
	else:
		engine_force = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"boost") and not _has_boosted and is_current_user:
		_has_boosted = true
		boost_sprite.modulate = Color(1.0, 1.0, 1.0, 0.4)
		# a bit a hacky way to enable the boost
		booster_entered(boost_increment, boost_duration)

func _update_particle_systems():
	var t = clampf(_speed / 6.0, 0.1, 1.0)
	
	var particle_velocity := linear_velocity.dot(transform.basis.z) * -1
	
	for particle_system in exhaust_particles:
		particle_system.amount_ratio = t
		particle_system.process_material.initial_velocity_min = particle_velocity
		particle_system.process_material.initial_velocity_max = particle_velocity
	
	var body =  wheel_bl.get_contact_body()
	var is_touching_ground := &"Terrain" in body.get_path().get_concatenated_names() if body else false
	wheel_particles_bl.emitting = is_touching_ground
	wheel_particles_br.emitting = is_touching_ground

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
		name_label.text = row.name
		owner_name = row.name
		
func _on_window_focus_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, false))
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), -80, 0, 0.5)

func _on_window_focus_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), 0, -80, 0.5)
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, true))
