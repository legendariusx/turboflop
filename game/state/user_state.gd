extends State

func _init() -> void:
	table_name = "user"
	query = "SELECT * FROM user"
	super._init()
