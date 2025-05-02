extends Node

var identity: PackedByteArray
var current_user: User

signal identity_updated(identity: PackedByteArray)
signal current_user_upated(user: User)

func _init():
	if SpacetimeDB.get_local_identity() == null:
		await SpacetimeDB.identity_received
		
	identity = SpacetimeDB.get_local_identity().identity
	identity_updated.emit(identity)
	
	UserState.update.connect(_on_user_update)

func is_current_user(user: User):
	return user == current_user

func _on_user_update(user: User):
	if user.identity == identity:
		current_user = user
		current_user_upated.emit(current_user)
