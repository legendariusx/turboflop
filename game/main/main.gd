extends Node3D

@onready var user_data = UserDataState.new()
# TODO: replace hard-coded track_id dynamically once on track
@onready var personal_best = PersonalBestState.new(1)

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
	personal_best.update.connect(_on_pesonal_best_updated)

func _on_user_updated(row: User):
	print("user updated: (name: %s, online: %s)" % [row.name, row.online])
	
func _on_user_data_updated(row: UserData):
	print("user_data updated:", row)

func _on_pesonal_best_updated(row: PersonalBest):
	print("personal best updated: (id: %s, track_id: %s, time: %s)" % [row.id, row.track_id, row.time])
	
func _on_update_user_data_button_pressed() -> void:
	UserData.set_user_data(Vector3(randf() * 10, randf() * 10, randf() * 10), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, false)
	UserData.set_user_data(Vector3(randf() * 10, randf() * 10, randf() * 10), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, false)
	
func _on_update_personal_best_button_pressed() -> void:
	PersonalBest.update_personal_best(1, randi())
