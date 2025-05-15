extends Camera3D

@export var target : Node3D
@export var distance := 10.0
@export var angle := 30.0
@export var follow_speed := 4.0

func _physics_process(delta: float) -> void:
	
	if target == null: return
	
	var offset = distance * Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(angle)).rotated(Vector3.UP, target.rotation.y	)
	var _target_position = target.position + offset
	
	position = position.lerp(_target_position, follow_speed * delta)
	
	look_at(target.global_position, Vector3.UP)
	
