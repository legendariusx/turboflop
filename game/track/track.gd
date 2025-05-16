class_name Track

extends Node3D

signal finished

@onready var player_vehicle: Vehicle = $Car
@onready var start_node: Checkpoint = $Start
@onready var checkpoints: Node = $Checkpoints
@onready var finishes: Node = $Finishes
@onready var last_checkpoint: Checkpoint = start_node

@export var track_id: int = -1

var started_at: int
var checkpoint_times: Array[int] = [0]

func _ready() -> void:
	# verify parent type
	assert(get_parent() is Main, "parent needs to be of type Main")
	
	# verify track_id is set
	assert(track_id != -1, "track_id needs to be set")
	
	# verify checkpoints and connect signals
	for checkpoint in checkpoints.get_children():
		assert(checkpoint is Checkpoint and checkpoint is not Finish, "children of Checkpoints must be of type Checkpoint and not of type Finish")
		(checkpoint as Checkpoint).checkpoint_entered.connect(func(): _on_checkpoint_entered(checkpoint))
	
	# verify finishes and connect signals
	assert(finishes.get_child_count() > 0, "one ore more finishes required")
	for finish in finishes.get_children():
		assert(finish is Finish, "children of Finishes must be of type Finish")
		(finish as Finish).finish_entered.connect(_on_finish_entered)
		
	# TODO: implement starting from user input
	_start()

func _start():
	# reset track state
	checkpoint_times.assign([0])
	last_checkpoint = start_node
	for checkpoint in checkpoints.get_children():
		(checkpoint as Checkpoint).was_entered = false
	
	# respawn player and start
	_respawn_at(start_node)
	started_at = Time.get_ticks_msec()

func _respawn_at(checkpoint: Checkpoint):
	# TODO: fix sometimes not resetting position
	player_vehicle.global_position = checkpoint.spawnpoint.global_position
	player_vehicle.global_rotation = checkpoint.spawnpoint.global_rotation
	player_vehicle.linear_velocity = Vector3.ZERO
	player_vehicle.angular_velocity = Vector3.ZERO
	player_vehicle.engine_force = 0

func _input(event: InputEvent) -> void:
	if event.is_action(&"respawn"):
		_respawn_at(last_checkpoint)
	elif event.is_action(&"reset"):
		_start()

func _on_checkpoint_entered(checkpoint: Checkpoint):
	checkpoint_times.append(Time.get_ticks_msec() - started_at)
	last_checkpoint = checkpoint

func _on_finish_entered():
	# check if all checkpoints were entered
	if not checkpoints.get_children().all(func(cp: Checkpoint): return cp.was_entered): return
	
	var finish_time: int = Time.get_ticks_msec() - started_at
	checkpoint_times.append(finish_time)
	
	PersonalBest.update_personal_best(track_id, finish_time, checkpoint_times)
	finished.emit()
