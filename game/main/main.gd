extends Node3D

@onready var user_data = UserDataState.new()

func _ready() -> void:
	# TODO: add dotenv config
	SpacetimeDB.connect_db(
		"http://localhost:3000",
		"turboflop",
		SpacetimeDBConnection.CompressionPreference.NONE,
		true,
		true
	)

	user_data.update.connect(_on_user_data_updated)
	UserState.update.connect(_on_user_updated)

func _on_user_updated(row: User):
	print("user updated:", row)

func _on_user_data_updated(row: UserData):
	print("user_data updated:", row)

func _on_button_pressed() -> void:
	UserData.set_user_data(Vector3(randf() * 10, randf() * 10, randf() * 10), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, false)
