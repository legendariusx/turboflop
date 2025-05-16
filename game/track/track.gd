class_name Track

extends Node3D

signal finished

@onready var player_vehicle: Vehicle = $Car
@onready var start_node: Checkpoint = $Start
@onready var checkpoints = $Checkpoints
@onready var finishes = $Finishes
@onready var last_checkpoint: Checkpoint = start_node

@export var track_id: int = -1

var started_at: int
var checkpoint_times: Array[int] = []
var finish_time: int

func _ready() -> void:
	# verify track_id is set
	assert(track_id != -1, "track_id needs to be set")
	
	# verify checkpoints and connect signals
	for checkpoint in checkpoints.get_children():
		assert(checkpoint is Checkpoint and checkpoint is not Finish, "child of Checkpoints must be of type Checkpoint and not of type Finish")
		(checkpoint as Checkpoint).checkpoint_entered.connect(_on_checkpoint_entered)
	
	# verify finishes and connect signals
	assert(finishes.get_child_count() > 0, "one ore more finishes required")
	for finish in finishes.get_children():
		assert(finish is Finish, "child of Finishes must be of type Finish")
		(finish as Finish).finish_entered.connect(_on_finish_entered)
		
	# TODO: implement starting from user input
	start()

func _input(event: InputEvent) -> void:
	if event.is_action(&"respawn"):
		respawn_at(last_checkpoint)
	elif event.is_action(&"reset"):
		start()

func start():
	# reset track state
	checkpoint_times.clear()
	last_checkpoint = start_node
	for checkpoint in checkpoints.get_children():
		(checkpoint as Checkpoint).was_entered = false
	
	# respawn player and start
	respawn_at(start_node)
	started_at = Time.get_ticks_msec()

func respawn_at(checkpoint: Checkpoint):
	player_vehicle.global_position = checkpoint.spawnpoint.global_position
	player_vehicle.global_rotation = checkpoint.spawnpoint.global_rotation
	player_vehicle.linear_velocity = Vector3.ZERO
	player_vehicle.angular_velocity = Vector3.ZERO
	player_vehicle.engine_force = 0

func _on_checkpoint_entered(checkpoint: Checkpoint):
	checkpoint_times.append(Time.get_ticks_msec() - started_at)
	last_checkpoint = checkpoint
	print("CP ENTERED")
	print(checkpoint_times)

func _on_finish_entered():
	if checkpoints.get_children().all(func(cp: Checkpoint): return cp.was_entered):
		finish_time = Time.get_ticks_msec() - started_at
		print("FINISHED")
		print(finish_time)
		PersonalBest.update_personal_best(track_id, finish_time)
		finished.emit()
	else:
		print("finish entered but not finished")
