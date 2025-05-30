class_name Main
extends Node3D

signal spacetime_connection_callback(success: bool)

const TRACK_PATH_TEMPLATE = &"res://tracks/track%s.tscn"

@onready var loading_screen: LoadingScreen = $LoadingScreen
@onready var main_menu: MainMenu = $MainMenu

var current_track: Track

func _ready() -> void:
	SpacetimeDB.connected.connect(func(): spacetime_connection_callback.emit(true))
	SpacetimeDB.connection_error.connect(func(_code: int, _reason: String): spacetime_connection_callback.emit(false))
	
	loading_screen.play_offline.connect(func(): _transition_to_main_menu(false))
	loading_screen.try_again.connect(_connect)
	
	main_menu.track_selected.connect(_load_track)
	
	_connect()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back_to_menu"):
		main_menu.display(SpacetimeDB.is_connected_db())
		if current_track:
			# FIXME: could probably be handled better than just deleting the current track
			# TODO: implement menu as menu rendered on top of track
			current_track.queue_free()

func _connect():
	loading_screen.show_connecting()
	
	# TODO: add dotenv config
	SpacetimeDB.connect_db(
		"http://localhost:3000",
		"turboflop",
		SpacetimeDBConnection.CompressionPreference.NONE,
		true,
		true
	)
	
	var success = await spacetime_connection_callback
	if success: _transition_to_main_menu(true)
	else: loading_screen.show_connection_failed()

func _load_track(track_id: int):
	# TODO: error-handling if file does not exist?
	var new_track: Track = load(TRACK_PATH_TEMPLATE % str(track_id).pad_zeros(3)).instantiate()
	
	main_menu.visible = false
	
	add_child(new_track)
	GameState.track_id = track_id
	current_track = new_track

func _transition_to_main_menu(connected: bool):
	loading_screen.visible = false
	main_menu.display(connected)
