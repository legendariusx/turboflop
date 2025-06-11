class_name PersonalBest

extends Resource

@export var id: int
@export var identity: PackedByteArray
@export var track_id: int
@export var time: int
@export var checkpoint_times: Array[int]
@export var date: int
@export var car_id: int

func _init():
	set_meta("table_name", &"personal_best")
	set_meta("primary_key", &"id")
	set_meta("bsatn_type_id", &"u64")
	set_meta("bsatn_type_identity", &"identity")
	set_meta("bsatn_type_track_id", &"u64")
	set_meta("bsatn_type_time", &"u64")
	set_meta("bsatn_type_checkpoint_times", &"u64")
	set_meta("bsatn_type_date", &"timestamp")
	set_meta("bsatn_type_car_id", &"u8")

# reducer - see server/lib::update_personal_best
static func update_personal_best(u_track_id: int, u_time: int, u_checkpoint_times: Array[int], u_car_id: int):
	if not SpacetimeDB.is_connected_db():
		await SpacetimeDB.connected
	
	SpacetimeDB.call_reducer("update_personal_best", [u_track_id, u_time, u_checkpoint_times, u_car_id])
