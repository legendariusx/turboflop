class_name CameraFollow

extends Camera3D

enum CameraMode{
	SMOOTH_FOLLOW = 0,
	FPV = 1
}

@export_group("Smooth Follow")
@export var distance := 10.0
@export var angle := 30.0
@export var follow_speed := 4.0

var camera_mode: CameraMode = CameraMode.SMOOTH_FOLLOW
var target: Node3D
var fpv_marker: Marker3D

var _is_stopped: bool = false

func _physics_process(delta: float) -> void:
	if target == null or _is_stopped: return
	
	match camera_mode:
		CameraMode.SMOOTH_FOLLOW:
			_smooth_follow(delta)
		CameraMode.FPV:
			_fpv()

func start() -> void:
	_is_stopped = false

func stop() -> void:
	_is_stopped = true
	
func cycle_camera_mode() -> void:
	camera_mode = (camera_mode + 1) % 2

func _smooth_follow(delta: float) -> void:
	var offset = distance * Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(angle)).rotated(Vector3.UP, target.rotation.y)
	var _target_position = target.position + offset
	
	position = position.lerp(_target_position, follow_speed * delta)
	
	look_at(target.global_position, Vector3.UP)

func _fpv() -> void:
	global_transform = fpv_marker.global_transform
