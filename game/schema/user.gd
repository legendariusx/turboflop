class_name User

extends Resource

@export var identity: PackedByteArray
@export var name: String
@export var online: bool

func _init():
	set_meta("table_name", "user")
	set_meta("primary_key", "identity")
	set_meta("bsatn_type_identity", "identity")
