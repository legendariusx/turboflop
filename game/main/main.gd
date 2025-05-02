extends Node3D

func _ready() -> void:
	# TODO: add dotenv config
	SpacetimeDB.connect_db(
		"http://localhost:3000",
		"turboflop",
		SpacetimeDBConnection.CompressionPreference.NONE,
		false,
		true
	)
