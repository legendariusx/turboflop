class_name Track

extends Node3D

enum TrackState {
	IDLE,
	COUNTDOWN,
	RUNNING,
	FINISHED
}

signal started
signal finished

const CAR_SCENE = preload("res://vehicles/car.scn")

@onready var player_vehicle: Vehicle = $Car
@onready var start_node: Checkpoint = $Start
@onready var checkpoints: Node = $Checkpoints
@onready var finishes: Node = $Finishes
@onready var opponents: Node = $Opponents
@onready var countdown_timer: Timer = $CountdownTimer

@onready var checkpoint_time_labels: VBoxContainer = $UI/CheckpointTimeLabels
@onready var stopwatch_label: Label = $UI/Stopwatch

@onready var last_checkpoint: Checkpoint = start_node

@onready var personal_best_state = PersonalBestState.new(track_id)
@onready var user_data = UserDataState.new()

@export var track_id: int = -1

var track_state = TrackState.IDLE
var started_at: int
var checkpoint_times: Array[int] = [0]
# FIXME bit of an ugly fix to allow player position updates based on _input
var respawn_location: Checkpoint

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
	
	# connect state
	user_data.update.connect(_on_user_data_updated)
	$TrackUI.connect_personal_best_state(personal_best_state)
	
	if SpacetimeDB.is_connected_db():
		player_vehicle.set_owner_data(GameState.identity, GameState.name)
		
	# TODO: implement starting from user input
	_start()

func _process(_delta: float) -> void:
	_on_update_ui()
	if respawn_location:
		_respawn_at(respawn_location)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		match track_state:
			TrackState.RUNNING:
				respawn_location = last_checkpoint
			TrackState.FINISHED:
				_start()
	elif event.is_action_pressed(&"reset"):
		_start()

func _start():
	# reset track state
	checkpoint_times.assign([0])
	last_checkpoint = start_node
	for checkpoint in checkpoints.get_children() + finishes.get_children():
		(checkpoint as Checkpoint).was_entered = false
	
	respawn_location = start_node
	
	_countdown()
	await started
	started_at = Time.get_ticks_msec()
	
#func _process(delta: float) -> void:
	#Noop 
	#

func _respawn_at(checkpoint: Checkpoint):
	player_vehicle.global_position = checkpoint.spawnpoint.global_position
	player_vehicle.global_rotation = checkpoint.spawnpoint.global_rotation
	player_vehicle.linear_velocity = Vector3.ZERO
	player_vehicle.angular_velocity = Vector3.ZERO
	player_vehicle.engine_force = 0
	respawn_location = null
	
func _countdown():
	_update_track_state(TrackState.COUNTDOWN)
	for i in range(3,0,-1):
		$TrackUI/Countdown.text = str(i)
		countdown_timer.start()
		await countdown_timer.timeout
	$TrackUI/Countdown.text = ""
	_update_track_state(TrackState.RUNNING)
	started.emit()

func _update_track_state(u_track_state: TrackState):
	track_state = u_track_state
	player_vehicle.is_input_enabled = track_state == TrackState.RUNNING
	if track_state == TrackState.COUNTDOWN: $TrackUI/Timer.text = "00.000"

func _on_update_ui():
	if track_state == TrackState.RUNNING:
		$TrackUI/Timer.text = TimeHelper.format_time_ms(Time.get_ticks_msec() - started_at)

func _on_user_data_updated(row: UserData):
	# ignore current users updates
	if GameState.identity == row.identity: return
	
	var opponent_index = opponents.get_children().find_custom(func(node: Vehicle): return node.owner_identity == row.identity)
	var opponent: Vehicle = opponents.get_children()[opponent_index] if opponent_index != -1 else null
	# opponent exists but is not active anymore -> remove
	if opponent and row.is_active == false:
		opponent.queue_free()
	# opponent exists and is active -> update data from row
	elif opponent != null:
		opponent.global_position = row.position
		opponent.rotation = row.rotation
		opponent.linear_velocity = row.linear_velocity
		opponent.angular_velocity = row.angular_velocity
	# otherwise if row is active and is on current track -> add new vehicle to container
	elif row.is_active and row.track_id == GameState.track_id:
		var user = UserState.find_by_pk(row.identity)
		if not user: return
		var new_vehicle = CAR_SCENE.instantiate()
		new_vehicle.set_owner_data(row.identity, user.name)
		opponents.add_child(new_vehicle)

func _on_checkpoint_entered(checkpoint: Checkpoint):
	var time = Time.get_ticks_msec() - started_at
	checkpoint_times.append(time)
	last_checkpoint = checkpoint
	
	_add_checkpoint_label(checkpoint_times.size(), time)

func _on_finish_entered():
	# store time immediately to minimize time increases due to process updates
	var finish_time = Time.get_ticks_msec() - started_at
	
	# check if all checkpoints were entered
	if not checkpoints.get_children().all(func(cp: Checkpoint): return cp.was_entered): return
	
	_update_track_state(TrackState.FINISHED)
	
	$TrackUI/Timer.text = TimeHelper.format_time_ms(finish_time)
	checkpoint_times.append(finish_time)
	
	PersonalBest.update_personal_best(track_id, finish_time, checkpoint_times)
	finished.emit()

func _add_checkpoint_label(index, time) -> void:
	var label = Label.new()
	label.text = str("Checkpoint ", index, ": ", time)
	checkpoint_time_labels.add_child(label)
