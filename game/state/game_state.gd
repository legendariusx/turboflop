extends Node

var identity: PackedByteArray
var current_user: User
var visibility: Enum.Visibility = Enum.Visibility.TRANSPARENT:
	set(u_visibility):
		visibility = u_visibility
		visibility_changed.emit(u_visibility)
var visibility_index: int = 1
var track_id: int = -1:
	set(u_track_id):
		track_id = u_track_id
		track_id_changed.emit(u_track_id)
var car_id: int = -1:
	set(u_car_id):
		car_id = u_car_id
		car_id_changed.emit(u_car_id)
var input_enabled := false:
	set(u_input_enabled):
		input_enabled = u_input_enabled
		input_enabled_changed.emit(input_enabled)
var track_state := Enum.TrackState.IDLE:
	set(u_track_state):
		track_state = u_track_state
		track_state_changed.emit(track_state)

signal identity_updated(identity: PackedByteArray)
signal current_user_updated(user: User)
signal visibility_changed(visibility: Enum.Visibility)
signal track_id_changed(track_id: int)
signal car_id_changed(car_id: int)
signal input_enabled_changed(input_enabled: bool)
signal track_state_changed(track_state: Enum.TrackState)

func _init():
	if SpacetimeDB.get_local_identity() == null:
		await SpacetimeDB.identity_received
		
	current_user = User.new()
		
	identity = SpacetimeDB.get_local_identity().identity
	identity_updated.emit(identity)
	
	UserState.update.connect(_on_user_update)

func is_current_user(user: User):
	return user == current_user

func _on_user_update(user: User):
	if user.identity == identity:
		current_user = user
		current_user_updated.emit(current_user)
		
		if not user.online or user.banned:
			SpacetimeDB.disconnect_db()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_opponent_visibility"):
		var new_visibility_index = visibility_index + 1 if visibility_index < 2 else 0
		visibility = Enum.Visibility.values()[new_visibility_index]
		visibility_index = new_visibility_index
		
