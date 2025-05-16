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
static func set_user_data(u_position: Vector3, u_rotation: Vector3, u_linear_velocity: Vector3, u_angular_velocity: Vector3, u_is_active: bool):
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
	SpacetimeDB.call_reducer("set_user_data", [u_position, u_rotation, u_linear_velocity, u_angular_velocity, u_is_active])
