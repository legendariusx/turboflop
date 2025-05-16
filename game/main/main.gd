class_name Main
extends Node3D

const TRACK_PATH_TEMPLATE = &"res://tracks/track%s.tscn"

var current_track: Track

func _ready() -> void:
	# TODO: add dotenv config
	SpacetimeDB.connect_db(
		"http://localhost:3000",
		"turboflop",
		SpacetimeDBConnection.CompressionPreference.NONE,
		true,
		true
	)

	UserState.update.connect(_on_user_updated)
	
	_load_track(1)

func _load_track(track_id: int):
	# TODO: error-handling if file does not exist?
	var new_track: Track = load(TRACK_PATH_TEMPLATE % str(track_id).pad_zeros(3)).instantiate()
	
	if current_track:
		current_track.queue_free()
		
	add_child(new_track)
	current_track = new_track

func _on_user_updated(row: User):
	print("user updated: (name: %s, online: %s)" % [row.name, row.online])

func _on_reload_track_button_pressed() -> void:
	_load_track(current_track.track_id)
