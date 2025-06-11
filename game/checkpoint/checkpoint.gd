class_name Checkpoint

extends Node3D

signal checkpoint_entered

const MATERIAL_LIGHT_GREEN = preload("res://assets/materials/PillarLightGreen.tres")
const MATERIAL_LIGHT_ORANGE = preload("res://assets/materials/PillarLightOrange.tres")
const MATERIAL_LIGHT_RED = preload("res://assets/materials/PillarLightRed.tres")

@onready var spawnpoint: Marker3D = $Spawnpoint
@onready var left_pillar_light_mesh: MeshInstance3D = $LeftPillarLight/MeshInstance3D
@onready var right_pillar_light_mesh: MeshInstance3D = $RightPillarLight/MeshInstance3D

var was_entered: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Vehicle and (body as Vehicle).is_current_user and not was_entered:
		checkpoint_entered.emit()

func set_light_color(color: Enum.LightColor):
	match color:
		Enum.LightColor.GREEN:
			_set_light_material(MATERIAL_LIGHT_GREEN)
		Enum.LightColor.ORANGE:
			_set_light_material(MATERIAL_LIGHT_ORANGE)
		Enum.LightColor.RED:
			_set_light_material(MATERIAL_LIGHT_RED)
	
func _set_light_material(material: Material):
	left_pillar_light_mesh.material_override = material
	right_pillar_light_mesh.material_override = material
