class_name CameraFollow

extends Camera3D

enum CameraMode{
	SMOOTH_FOLLOW,
	FPV,
	CINEMATIC
}

@export_group("Smooth Follow")
@export var distance: float = 10.0
@export var angle: float = 30.0
@export var follow_speed: float = 4.0

@export_group("Cinematic")
@export var height: float = 10.0
@export var max_distance: float = 40.0

var camera_mode: CameraMode = CameraMode.SMOOTH_FOLLOW
var target: RigidBody3D
var fpv_marker: Marker3D

var _is_stopped: bool = false

func _physics_process(delta: float) -> void:
	if target == null or _is_stopped: return
	
	match camera_mode:
		CameraMode.SMOOTH_FOLLOW:
			_smooth_follow(delta)
		CameraMode.FPV:
			_fpv()
		CameraMode.CINEMATIC:
			_cinematic()

func start() -> void:
	_is_stopped = false

func stop() -> void:
	_is_stopped = true
	
func cycle_camera_mode() -> void:
	camera_mode = (camera_mode + 1) % CameraMode.size()
	
	if camera_mode == CameraMode.CINEMATIC:
		_set_new_cinematic_position()

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
	var forward_direction = (target.transform.basis.x + target.transform.basis.y + target.transform.basis.z).normalized()

	forward_direction = forward_direction.normalized()
	
	var offset = forward_direction * (max_distance - 10)
	offset.y = height
	global_position = target.global_position + offset
