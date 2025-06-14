class_name Main
extends Node3D

signal spacetime_connection_callback(success: bool)

const TRACK_PATH_TEMPLATE := &"res://tracks/track%s.tscn"

@onready var loading_screen: LoadingScreen = $LoadingScreen
@onready var main_menu: MainMenu = $MainMenu

var current_track: Track

func _ready() -> void:
	SpacetimeDB.connected.connect(func(): spacetime_connection_callback.emit(true))
	SpacetimeDB.connection_error.connect(func(_code: int, _reason: String): spacetime_connection_callback.emit(false))
	SpacetimeDB.disconnected.connect(_on_disconnected)
	
	loading_screen.play_offline.connect(func(): _transition_to_main_menu(false))
	loading_screen.try_again.connect(_connect)
	
	main_menu.track_and_car_selected.connect(_load_track)
	
	_connect()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back_to_menu"):
		main_menu.display(SpacetimeDB.is_connected_db())
		if current_track:
			# FIXME: could probably be handled better than just deleting the current track
			# TODO: implement menu as menu rendered on top of track
			current_track.queue_free()

func _connect():
	main_menu.hide()
	loading_screen.show_connecting()
	
	# TODO: add dotenv config
	SpacetimeDB.connect_db(
		URLHelper.get_spacetimedb_url(),
		"turboflop",
		SpacetimeDBConnection.CompressionPreference.NONE,
		OS.get_name() != "Web" or URLHelper.is_localhost(),
		true
	)
	
	var success = await spacetime_connection_callback
	if success: _transition_to_main_menu(true)
	else: loading_screen.show_connection_failed()

func _load_track(track_id: int, car_id: int):
	# TODO: error-handling if file does not exist?
	var new_track: Track = load(TRACK_PATH_TEMPLATE % str(track_id).pad_zeros(3)).instantiate()
	var new_car: Vehicle = CarHelper.get_new_car_by_id(car_id)
	
	new_track.set_car(new_car)
	main_menu.visible = false
	
	add_child(new_track)
	GameState.track_id = track_id
	GameState.car_id = car_id
	current_track = new_track
	
	current_track.start()

func _transition_to_main_menu(connected: bool):
	loading_screen.visible = false
	main_menu.display(connected)

func _on_disconnected():
	if current_track:
		current_track.queue_free()
	loading_screen.show_connection_failed()
	main_menu.hide()
