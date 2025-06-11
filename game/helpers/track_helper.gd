extends Node

const TRACKS_BASE_PATH := "res://tracks/"

var track_scenes: Array[Track] = []

func _init():
	_load_track_scenes()
	
func _load_track_scenes():
	var dir = DirAccess.open(TRACKS_BASE_PATH)
	var track_names: Array[String] = []
	
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if "track" in file_name and "tscn" in file_name:
			track_names.append(file_name)
		file_name = dir.get_next()
	 
	track_names.sort()
	for track_name in track_names:
		var track_scene := (load(TRACKS_BASE_PATH + track_name.replace(".remap", "")).instantiate() as Track)
		track_scenes.append(track_scene)

func _get_track_by_id(track_id: int):
	var index := track_scenes.find_custom(func(track_scene: Track): return track_scene.car_id == track_id)
	if index != -1:
		return track_scenes[index].duplicate()
