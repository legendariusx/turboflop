class_name UserDataState

extends State

func _init() -> void:
	table_name = "user_data"
	query = "SELECT * FROM user_data"
	super._init()
