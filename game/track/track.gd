class_name Track

extends Node3D

signal finished

@onready var player_vehicle: Vehicle = $Car
@onready var start_node: Start = $Start
@onready var checkpoints = $Checkpoints
@onready var finishes = $Finishes

@export var track_id: int = -1

var started_at: int
var checkpoint_times: Array[int] = []
var finish_time: int

func _ready() -> void:
	# verify track_id is set
	assert(track_id != -1, "track_id needs to be set")
	
	# verify checkpoints and connect signals
	for checkpoint in checkpoints.get_children():
		assert(checkpoint is Checkpoint and checkpoint is not Start and checkpoint is not Finish, "child of Checkpoints must be of type Checkpoint and neither type Start nor Finish")
		(checkpoint as Checkpoint).checkpoint_entered.connect(_on_checkpoint_entered)
	
	# verify finishes and connect signals
	assert(finishes.get_child_count() > 0, "one ore more finishes required")
	for finish in finishes.get_children():
		assert(finish is Finish, "child of Finishes must be of type Finish")
		(finish as Finish).finish_entered.connect(_on_finish_entered)
		
	# TODO: implement starting from user input
	start()

func start():
	player_vehicle.global_position = start_node.spawnpoint.global_position
	player_vehicle.global_rotation = start_node.spawnpoint.global_rotation
	started_at = Time.get_ticks_msec()

func _on_checkpoint_entered():
	checkpoint_times.append(Time.get_ticks_msec() - started_at)
	print("CP ENTERED")
	print(checkpoint_times)

func _on_finish_entered():
	if checkpoints.get_children().all(func(cp: Checkpoint): return cp.was_entered):
		finish_time = Time.get_ticks_msec() - started_at
		print("FINISHED")
		print(finish_time)
		PersonalBest.update_personal_best(track_id, finish_time)
	else:
		print("finish entered but not finished")
