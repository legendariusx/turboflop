class_name Track

extends Node3D

signal started
signal finished(time: int)

@export var track_id: int = -1

@onready var camera: CameraFollow = $Camera3D
@onready var start_node: Checkpoint = $Start
@onready var checkpoints: Node = $Checkpoints
@onready var finishes: Node = $Finishes
@onready var opponents: Node = $Opponents
@onready var countdown_timer: Timer = $CountdownTimer
@onready var countdown_sound: AudioStreamPlayer = $CountdownSound
@onready var checkpoint_sound: AudioStreamPlayer = $CheckpointSound
@onready var track_ui: TrackUI = $TrackUI

@onready var last_checkpoint: Checkpoint = start_node

@onready var personal_best_state = PersonalBestState.new(self, track_id)
@onready var user_data = UserDataState.new(self)

var player_vehicle: Vehicle
var started_at: int
var checkpoint_times: Array[int] = [0]

# FIXME bit of an ugly fix to allow player position updates based on _input
var respawn_location: Checkpoint

var _checkpoint_index: int = -1

func set_car(car: Vehicle) -> void:
	player_vehicle = car
	player_vehicle.set_owner_data(GameState.identity, GameState.current_user.name)
	add_child(player_vehicle)

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
	
	user_data.update.connect(_on_user_data_updated)
	
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)
	
	if SpacetimeDB.is_connected_db():
		if not GameState.current_user: await GameState.current_user_updated
	
	camera.target = player_vehicle
	camera.fpv_marker = player_vehicle.fpv_marker

func _process(_delta: float) -> void:
	_on_update_ui()
	if player_vehicle.global_position.y < -100:
		respawn_location = last_checkpoint
	
	if respawn_location:
		_respawn_at(respawn_location)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"respawn"):
		match GameState.track_state:
			Enum.TrackState.RUNNING:
				respawn_location = last_checkpoint
			Enum.TrackState.FINISHED:
				start()
	elif event.is_action_pressed(&"reset"):
		start()
	elif event.is_action_pressed(&"cycle_camera_mode"):
		camera.cycle_camera_mode()

func _exit_tree() -> void:
	UserData.set_user_data(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, false, 0, 0)

func start():
	randomize()
	# reset track state
	checkpoint_times.assign([0])
	last_checkpoint = start_node
	_checkpoint_index = -1
	for checkpoint in checkpoints.get_children() + finishes.get_children():
		(checkpoint as Checkpoint).was_entered = false
		(checkpoint as Checkpoint).set_light_color(Enum.LightColor.RED)
		
	start_node.set_light_color(Enum.LightColor.GREEN)
	start_node.was_entered = true
	
	if checkpoints.get_children().size() > 0:
		checkpoints.get_children()[0].set_light_color(Enum.LightColor.ORANGE)
	
	track_ui.reset()
	camera.start()
	
	respawn_location = start_node
	
	_checkpoint_index = -1
	_set_next_checkpoint()
	
	_countdown()
	await started
	started_at = Time.get_ticks_msec()
	
	# hacky way to reset car boost
	player_vehicle._has_boosted = false
	player_vehicle.boost_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _respawn_at(checkpoint: Checkpoint):
	player_vehicle.global_position = checkpoint.spawnpoint.global_position
	player_vehicle.global_rotation = checkpoint.spawnpoint.global_rotation
	player_vehicle.linear_velocity = Vector3.ZERO
	player_vehicle.angular_velocity = Vector3.ZERO
	player_vehicle.engine_force = 0
	player_vehicle.boost_timer.stop()
	player_vehicle.on_boost_timer_timeout()
	respawn_location = null
	
func _countdown():
	_update_track_state(Enum.TrackState.COUNTDOWN)
	for i in range(3,0,-1):
		countdown_sound.play()
		track_ui.countdown.text = str(i)
		countdown_timer.start()
		await countdown_timer.timeout
		countdown_sound.stop()
	countdown_sound.play(2.95)
	track_ui.countdown.text = ""
	_update_track_state(Enum.TrackState.RUNNING)
	started.emit()

func _update_track_state(u_track_state: Enum.TrackState):
	GameState.track_state = u_track_state
	
	match u_track_state:
		Enum.TrackState.COUNTDOWN:
			track_ui.timer.text = "00.000"
			GameState.input_enabled = false
		Enum.TrackState.RUNNING:
			GameState.input_enabled = true
		Enum.TrackState.FINISHED:
			GameState.input_enabled = false

func _on_update_ui():
	if GameState.track_state == Enum.TrackState.RUNNING:
		track_ui.timer.text = TimeHelper.format_time_ms(Time.get_ticks_msec() - started_at)

func _on_user_data_updated(row: UserData):
	# ignore current users updates
	if GameState.identity == row.identity: return
	
	var opponent_index = opponents.get_children().find_custom(func(node: Vehicle): return node.owner_identity == row.identity)
	var opponent: Vehicle = opponents.get_children()[opponent_index] if opponent_index != -1 else null
	# opponent exists but is not active anymore -> remove
	if opponent and (not row.is_active or row.track_id != GameState.track_id):
		opponent.queue_free()
	# opponent exists and is active -> update data from row
	elif opponent != null:
		opponent.global_position = row.position
		opponent.rotation = row.rotation
		opponent.linear_velocity = row.linear_velocity
		opponent.angular_velocity = row.angular_velocity
	# otherwise if row is active and is on current track -> add new vehicle to container
	elif row.is_active and row.track_id == GameState.track_id and row.car_id != 0:
		var user := UserState.find_by_pk(row.identity)
		if not user: return
		var new_vehicle = CarHelper.get_car_by_id(row.car_id)
		new_vehicle.set_owner_data(row.identity, user.name)
		opponents.add_child(new_vehicle)

func _on_checkpoint_entered(checkpoint: Checkpoint):
	var checkpoint_instances = checkpoints.get_children()
	
	# TODO: change logic after presentation - this was intended behavior
	if _checkpoint_index >= checkpoint_instances.size() or checkpoint_instances[_checkpoint_index] != checkpoint:
		return
	
	var time = Time.get_ticks_msec() - started_at
	checkpoint_times.append(time)
	last_checkpoint = checkpoint
	
	checkpoint.was_entered = true
	checkpoint.set_light_color(Enum.LightColor.GREEN)
	
	track_ui.on_checkpoint_entered(checkpoint_times.size() - 1, time)
	_set_next_checkpoint()
	checkpoint_sound.play()

func _on_finish_entered(_finish: Finish):
	# store time immediately to minimize time increases due to process updates
	var finish_time = Time.get_ticks_msec() - started_at
	
	# check if all checkpoints were entered
	if not checkpoints.get_children().all(func(cp: Checkpoint): return cp.was_entered):
		return
		
	for f in finishes.get_children():
		(f as Checkpoint).was_entered = true
		(f as Checkpoint).set_light_color(Enum.LightColor.GREEN)
	
	_update_track_state(Enum.TrackState.FINISHED)
	
	checkpoint_times.append(finish_time)
	track_ui.timer.text = TimeHelper.format_time_ms(finish_time)
	checkpoint_sound.play()
	camera.stop()
	
	PersonalBest.update_personal_best(track_id, finish_time, checkpoint_times, player_vehicle.car_id)
	finished.emit(finish_time)

func _set_next_checkpoint():
	_checkpoint_index += 1
	var checkpoint_instances = checkpoints.get_children()
	
	if _checkpoint_index < checkpoint_instances.size():
		checkpoint_instances[_checkpoint_index].set_light_color(Enum.LightColor.ORANGE)
	else:
		for finish in finishes.get_children():
			finish.set_light_color(Enum.LightColor.ORANGE)

func _on_window_focus_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, false))
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), -80, GameState.volume, 0.5)

func _on_window_focus_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(func(v): AudioServer.set_bus_volume_db(0, v), GameState.volume, -80, 0.5)
	tween.tween_callback(AudioServer.set_bus_mute.bind(0, true))
