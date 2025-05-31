class_name User

extends Resource

@export var identity: PackedByteArray
@export var name: String
@export var online: bool
@export var admin: bool

func _init():
	set_meta("table_name", "user")
	set_meta("primary_key", "identity")
	set_meta("bsatn_type_identity", "identity")

# reducer - see server/lib::set_name
static func set_name_reducer(u_name: String):
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
	SpacetimeDB.call_reducer("set_name", [u_name])
