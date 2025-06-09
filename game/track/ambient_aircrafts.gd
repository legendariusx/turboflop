class_name AmbientAircrafts
extends Node3D

@export var aircraft_scenes: Array[PackedScene]
@export var max_aircrafts: int = 5
@export var min_spawn_height: float = 75.0
@export var max_spawn_height: float = 125.0

func _ready() -> void:
	randomize()
	
	for i in range(max_aircrafts):
		_spawn_new_aircraft()
	
func _process(_delta: float) -> void:
	pass
	
func _spawn_new_aircraft() -> void:
	var new_aircraft_scene: Node3D = aircraft_scenes[randi() % aircraft_scenes.size()].instantiate()
	add_child(new_aircraft_scene)
	
	var spawn_size = 100.0
	new_aircraft_scene.global_position = Vector3(randf_range(-spawn_size, spawn_size), randf_range(-spawn_size, spawn_size), randf_range(min_spawn_height,max_spawn_height))
	
	pass
