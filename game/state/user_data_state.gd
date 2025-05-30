class_name UserDataState

extends State

func _init(parent: Node) -> void:
	table_name = "user_data"
	query = "SELECT * FROM user_data"
	super._init(parent)
