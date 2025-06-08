class_name MainMenu

extends Control

signal track_and_car_selected(track_id: int, car_id: int)

const USERNAME_MIN_LENGTH = 4

@export var track_select_scene: PackedScene
@export var car_select_scene: PackedScene

@onready var username_container = $CenterContainer/VBoxContainer/UsernameContainer
@onready var name_input = $CenterContainer/VBoxContainer/UsernameContainer/HBoxContainer/NameInput
@onready var confirm_button = $CenterContainer/VBoxContainer/UsernameContainer/HBoxContainer/Confirm
@onready var track_selection_container = $CenterContainer/VBoxContainer/TrackSelectionContainer
@onready var track_container = $CenterContainer/VBoxContainer/TrackSelectionContainer/TrackContainer
@onready var car_selection_container = $CenterContainer/VBoxContainer/CarSelectionContainer
@onready var car_container = $CenterContainer/VBoxContainer/CarSelectionContainer/CarContainer
@onready var change_username_container = $ChangeUsernameContainer
@onready var change_username_container_label = $ChangeUsernameContainer/Label

var _selected_track_id: int = -1

func _ready():
	GameState.current_user_updated.connect(_on_current_user_updated)

func display(connected: bool):
	visible = true
	if connected and not GameState.current_user: await GameState.current_user_updated
	
	if GameState.current_user.name == "":
		_render_username_selection()
	else:
		_render_track_selection()

func _render_username_selection():
	username_container.visible = true
	track_selection_container.visible = false
	car_selection_container.visible = false
	change_username_container.visible = false

func _render_track_selection():
	username_container.visible = false
	track_selection_container.visible = true
	car_selection_container.visible = false
	change_username_container.visible = true
	
	if track_container.get_child_count() > 0:
		return
	
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
		new_button.pressed.connect(func(): _track_selected(clean_track_name.to_int()))
		track_container.add_child(new_button)
		
func _render_car_selection():
	username_container.visible = false
	track_selection_container.visible = false
	car_selection_container.visible = true
	change_username_container.visible = true
	
	if car_container.get_child_count() > 0:
		return
	
	for i in 100:
		var file_name = &"res://vehicles/car%s.tscn" % str(i).pad_zeros(3)
		if not FileAccess.file_exists(file_name):
			continue
			
		var car_scene = load(file_name).instantiate()
		var car_name = (car_scene as Vehicle).car_name
		var car_id = (car_scene as Vehicle).car_id
		
		var new_car_select_scene = car_select_scene.instantiate()
		new_car_select_scene.button.text = car_name
		new_car_select_scene.button.pressed.connect(func(): track_and_car_selected.emit(_selected_track_id, car_id))
		car_container.add_child(new_car_select_scene)
		
func _track_selected(track_id: int) -> void:
	_selected_track_id = track_id
	_render_car_selection()

func _on_name_input_text_submitted(new_text: String) -> void:
	_on_confirm(new_text)

func _on_name_input_text_changed(new_text: String) -> void:
	confirm_button.disabled = len(new_text) < USERNAME_MIN_LENGTH
	
func _on_confirm_pressed() -> void:
	_on_confirm(name_input.text)

func _on_current_user_updated(user: User):
	change_username_container_label.text = user.name

func _on_confirm(u_name: String):
	if len(name_input.text) < USERNAME_MIN_LENGTH: return
	
	if GameState.current_user.online:
		User.set_name_reducer(u_name)
		await GameState.current_user_updated
	else:
		GameState.current_user.name = u_name
			
	display(GameState.current_user.online)

func _on_change_username_pressed() -> void:
	_render_username_selection()
