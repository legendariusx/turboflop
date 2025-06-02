class_name MainMenu

extends Control

signal track_selected(track_id: int)

const USERNAME_MIN_LENGTH = 4

@export var track_select_scene: PackedScene

@onready var username_container = $CenterContainer/VBoxContainer/UsernameContainer
@onready var name_input = $CenterContainer/VBoxContainer/UsernameContainer/HBoxContainer/NameInput
@onready var confirm_button = $CenterContainer/VBoxContainer/UsernameContainer/HBoxContainer/Confirm
@onready var track_selection_container = $CenterContainer/VBoxContainer/TrackSelectionContainer
@onready var track_container = $CenterContainer/VBoxContainer/TrackSelectionContainer/TrackContainer

func display(connected: bool):
	visible = true
	if connected and not GameState.current_user: await GameState.current_user_upated
	
	if GameState.current_user.name == "":
		_render_username_selection()
	elif track_container.get_child_count() == 0:
		_render_track_selection()

func _render_username_selection():
	username_container.visible = true
	track_selection_container.visible = false

func _render_track_selection():
	username_container.visible = false
	track_selection_container.visible = true
		
	var dir = DirAccess.open("res://tracks")
	var track_names: Array[String] = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "" and "track" in file_name:
			track_names.append(file_name)
			file_name = dir.get_next()
	
	track_names.sort()
	for track_name in track_names:
		var new_button = track_select_scene.instantiate()
		var clean_track_name = track_name.replace("track", "").replace(".tscn", "").replace(".remap", "")
		new_button.text = clean_track_name
		new_button.pressed.connect(func(): track_selected.emit(clean_track_name.to_int()))
		track_container.add_child(new_button)

func _on_name_input_text_submitted(new_text: String) -> void:
	_on_confirm(new_text)

func _on_name_input_text_changed(new_text: String) -> void:
	confirm_button.disabled = len(new_text) < USERNAME_MIN_LENGTH
	
func _on_confirm_pressed() -> void:
	_on_confirm(name_input.text)

func _on_confirm(u_name: String):
	if len(name_input.text) < USERNAME_MIN_LENGTH: return
	
	if GameState.current_user.online:
		User.set_name_reducer(u_name)
		await GameState.current_user_upated
	else:
		GameState.current_user.name = u_name
			
	display(GameState.current_user.online)
