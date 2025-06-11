extends Node

const VEHICLES_BASE_PATH := "res://vehicles/"

var car_scenes: Array[Vehicle] = []

func _init():
	_load_car_scenes()
	
func _load_car_scenes():
	var dir := DirAccess.open(VEHICLES_BASE_PATH)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "" and "car" in file_name:
		var car_scene := (load(VEHICLES_BASE_PATH + file_name.replace(".remap", "")).instantiate() as Vehicle)
		car_scenes.append(car_scene)
		file_name = dir.get_next()

func get_car_by_id(car_id: int):
	var index := car_scenes.find_custom(func(car_scene: Vehicle): return car_scene.car_id == car_id)
	if index != -1:
		return car_scenes[index].duplicate()
