class_name CameraFollow

extends Camera3D

enum CameraMode{
	SMOOTH_FOLLOW,
	FPV,
	CINEMATIC,
	FREE_FLIGHT
}

@export_group("Smooth Follow")
@export var distance: float = 10.0
@export var angle: float = 30.0
@export var follow_speed: float = 4.0

@export_group("Cinematic")
@export var height: float = 10.0
@export var max_distance: float = 40.0

@export_group("Free Flight")
@export var mouse_sensitivity: float = 0.1
@export var speed: float = 1.0

var camera_mode: CameraMode = CameraMode.SMOOTH_FOLLOW
var target: RigidBody3D
var fpv_marker: Marker3D

var _is_stopped: bool = false
var _rotation_x: float = 0.0
var _rotation_y: float = 0.0

func start() -> void:
	_is_stopped = false

func stop() -> void:
	_is_stopped = true
	
func cycle_camera_mode() -> void:
	camera_mode = ((camera_mode + 1) % CameraMode.size()) as CameraMode
	
	if camera_mode == CameraMode.CINEMATIC:
		_set_new_cinematic_position()
		
	if camera_mode == CameraMode.FREE_FLIGHT:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GameState.input_enabled = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if target == null or _is_stopped: return
	
	match camera_mode:
		CameraMode.SMOOTH_FOLLOW:
			_smooth_follow(delta)
		CameraMode.FPV:
			_fpv()
		CameraMode.CINEMATIC:
			_cinematic()
		CameraMode.FREE_FLIGHT:
			_free_flight()
			
func _input(event):
	if event is InputEventMouseMotion and camera_mode == CameraMode.FREE_FLIGHT:
		_rotation_y -= event.relative.x * mouse_sensitivity
		_rotation_x -= event.relative.y * mouse_sensitivity
		_rotation_x = clamp(_rotation_x, -90, 90)
		rotation_degrees = Vector3(_rotation_x, _rotation_y, 0)
		
func _unhandled_input(event):
	# go back to normal mouse mode when entering the main menu
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _smooth_follow(delta: float) -> void:
	var offset = distance * Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(angle)).rotated(Vector3.UP, target.rotation.y)
	var _target_position = target.position + offset
	
	position = position.lerp(_target_position, follow_speed * delta)
	
	look_at(target.global_position, Vector3.UP)

func _fpv() -> void:
	global_transform = fpv_marker.global_transform

func _cinematic() -> void:
	if global_position.distance_to(target.global_position) > max_distance:
		_set_new_cinematic_position()
		
	look_at(target.global_position, Vector3.UP)
	
func _set_new_cinematic_position() -> void:
	var forward_direction = -global_transform.basis.z
	var offset = forward_direction * (max_distance - 10)
	offset.y = height
	global_position = target.global_position + offset
	
func _free_flight() -> void:
	var left_right = Input.get_axis(&"turn_right", &"turn_left")
	var forward_backward = Input.get_axis(&"reverse", &"accelerate")

	var view_dir = -global_transform.basis.z
	var offset = view_dir * speed * forward_backward + view_dir.rotated(Vector3(0.0, 1.0, 0.0), deg_to_rad(90)) * speed * left_right
	global_position += offset
