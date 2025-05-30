class_name PersonalBestState

extends State

func _init(parent: Node, track_id: int) -> void:
	table_name = "personal_best"
	query = "SELECT * FROM personal_best WHERE track_id=" + str(track_id)
	super._init(parent)
