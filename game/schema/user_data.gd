class_name UserData

extends Resource

@export var identity: PackedByteArray
@export var position: Vector3
@export var rotation: Vector3
@export var linear_velocity: Vector3
@export var angular_velocity: Vector3
@export var is_active: bool

func _init():
	set_meta("table_name", "user_data")
	set_meta("primary_key", "identity")
	set_meta("bsatn_type_identity", "identity")

# reducer - see server/lib::set_user_data
static func set_user_data(position: Vector3, rotation: Vector3, linear_velocity: Vector3, angular_velocity: Vector3, is_active: bool):
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
	SpacetimeDB.call_reducer("set_user_data", [position, rotation, linear_velocity, angular_velocity, is_active])
