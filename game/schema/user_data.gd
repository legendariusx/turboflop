class_name UserData

extends Resource

@export var identity: PackedByteArray
@export var position: Vector3
@export var rotation: Vector3
@export var linear_velocity: Vector3
@export var angular_velocity: Vector3
@export var is_active: bool
@export var track_id: int
@export var car_id: int

func _init():
	set_meta("table_name", "user_data")
	set_meta("primary_key", "identity")
	set_meta("bsatn_type_identity", "identity")
	set_meta("bsatn_type_track_id", "u8")
	set_meta("bsatn_type_car_id", "u8")

# reducer - see server/lib::set_user_data
static func set_user_data(u_position: Vector3, u_rotation: Vector3, u_linear_velocity: Vector3, u_angular_velocity: Vector3, u_is_active: bool, u_track_id: int, u_car_id: int):
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
	SpacetimeDB.call_reducer("set_user_data", [u_position, u_rotation, u_linear_velocity, u_angular_velocity, u_is_active, u_track_id, u_car_id])
