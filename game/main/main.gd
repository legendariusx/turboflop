class_name Main
extends Node3D

@onready var user_data = UserDataState.new()

const TRACKS_PATH = "res://tracks/track"

var current_track: Track
var personal_best: PersonalBestState

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
	user_data.update.connect(_on_user_data_updated)
	
	_load_track(1)

func _load_track(track_id: int):
	# TODO: error-handling if file does not exist?
	var new_track: Track = load(TRACKS_PATH + str(track_id).pad_zeros(3) + ".tscn").instantiate()
	var new_personal_best: PersonalBestState = preload("res://state/personal_best_state.gd").new(track_id)
	new_personal_best.update.connect(_on_pesonal_best_updated)
	
	if current_track:
		current_track.queue_free()
		personal_best.queue_free()
		
	add_child(new_track)
	current_track = new_track
	personal_best = new_personal_best

func _on_user_updated(row: User):
	print("user updated: (name: %s, online: %s)" % [row.name, row.online])
	
func _on_user_data_updated(row: UserData):
	print("user_data updated:", row)

func _on_pesonal_best_updated(row: PersonalBest):
	print("personal best updated: (id: %s, track_id: %s, time: %s)" % [row.id, row.track_id, row.time])

func _on_reload_track_button_pressed() -> void:
	_load_track(current_track.track_id)
