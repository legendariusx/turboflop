class_name Checkpoint

extends Node3D

signal checkpoint_entered

@onready var spawnpoint: Marker3D = $Spawnpoint

var was_entered: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Vehicle and (body as Vehicle).is_current_user and not was_entered:
		checkpoint_entered.emit()
		was_entered = true
