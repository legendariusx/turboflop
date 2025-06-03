class_name Booster

extends Node3D

@export var boost_multiplier: float = 1.2
@export var boost_duration: float = 1.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Vehicle and (body as Vehicle):
		(body as Vehicle).booster_entered(boost_multiplier, boost_duration)
