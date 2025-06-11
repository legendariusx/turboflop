class_name UserDataState

extends State

func _init(parent: Node) -> void:
	table_name = "user_data"
	query = "SELECT * FROM user_data WHERE identity != 0x%s" % GameState.identity.hex_encode()
	super._init(parent)
