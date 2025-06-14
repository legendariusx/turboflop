class_name TrackUI

extends Control

const MAX_SCORES = 10

@onready var countdown: Label = $Countdown
@onready var timer: Label = $Timer
@onready var scoreboard: Tree = $Scoreboard
@onready var cp_times: Tree = $CheckpointTimes
@onready var cp_split: CPSplit = $CPSplit
@onready var keybinds_button: Button = $KeybindsButton
@onready var keybinds: VBoxContainer = $Keybinds
@onready var volume_slider: HSlider = $VolumeContainer/VolumeSlider

var personal_best_state: PersonalBestState
var cp_tree_root: TreeItem

func _ready():
	# parent has to be Track in order to connect relevant signals
	assert(get_parent() is Track, "parent of TrackUI has to be of type Track")
	
	var parent: Track = get_parent()
	if not parent.is_node_ready(): await parent.ready
	
	parent.finished.connect(_on_finished)
	
	personal_best_state = parent.personal_best_state
	personal_best_state.update.connect(func(_row): _update_ui())
	personal_best_state.delete.connect(func(_row): _update_ui())
	
	UserState.update.connect(func(_row): _update_ui())
	UserState.delete.connect(func(_row): _update_ui())
	
	scoreboard.set_column_title(0, "#")
	scoreboard.set_column_title(1, "Player")
	scoreboard.set_column_title(2, "Car")
	scoreboard.set_column_title(3, "Time")
	
	scoreboard.set_column_expand_ratio(0, 1)
	scoreboard.set_column_expand_ratio(1, 10)
	scoreboard.set_column_expand_ratio(2, 5)
	scoreboard.set_column_expand_ratio(3, 10)
	
	scoreboard.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	
	cp_times.set_column_title(0, "#")
	cp_times.set_column_title(1, "Time")
	
	cp_times.set_column_expand_ratio(0, 1)
	cp_times.set_column_expand_ratio(1, 2)
	
	_on_volume_slider_value_changed(GameState.volume)

func _process(_delta: float) -> void:
	scoreboard.visible = Input.is_action_pressed("show_scoreboard")

func reset():
	cp_times.clear()
	cp_tree_root = cp_times.create_item()
	_hide_checkpoint_time()

func on_checkpoint_entered(index: int, time: int):
	_add_checkpoint_label("%02d" % index, time)
	_show_checkpoint_time("%02d" % index, index, time, false)

func _on_finished(time: int):
	_add_checkpoint_label("F", time)
	_show_checkpoint_time("F", (get_parent() as Track).checkpoint_times.size() - 1, time, true)

func _update_ui():
	scoreboard.clear()
	var tree_root = scoreboard.create_item()
	
	var sorted_pbs = personal_best_state.data.duplicate()
	var num_items = MAX_SCORES
	
	sorted_pbs.sort_custom(func(a, b): return a.time - b.time < 0)
	
	var current_player_index = sorted_pbs.find_custom(func(pb): return pb.identity == GameState.identity)
	var current_player_not_in_top = current_player_index >= MAX_SCORES and current_player_index != -1
	if current_player_not_in_top:
		num_items -= 1
	
	for i in range(0, min(len(sorted_pbs), num_items)):
		var pb = sorted_pbs[i]
		var user = UserState.find_by_pk(pb.identity)
		if not user: continue
		var player_name = user.name
		if pb.identity == GameState.identity: player_name += " (You)"
		_create_scoreboard_row(tree_root, i + 1, player_name, pb.time, pb.car_id)

	if current_player_not_in_top:
		_create_scoreboard_row(tree_root, current_player_index + 1, GameState.current_user.name + " (You)", sorted_pbs[current_player_index].time, sorted_pbs[current_player_index].car_id)

func _create_scoreboard_row(root: TreeItem, placement: int, player_name: String, time: int, car_id: int):
	var new_row = scoreboard.create_item(root)
	new_row.set_text(0, str(placement))
	new_row.set_text(1, player_name) 
	new_row.set_text(2, CarHelper.get_car_name_by_id(car_id))
	new_row.set_text(3, TimeHelper.format_time_ms(time)) 
	
	new_row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)

func _add_checkpoint_label(number: String, time: int) -> void:
	var new_row = cp_times.create_item(cp_tree_root)
	new_row.set_text(0, number)
	new_row.set_text(1, TimeHelper.format_time_ms(time))
	
	new_row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	
	cp_times.scroll_to_item(new_row)

func _show_checkpoint_time(checkpoint_text: String, index: int, time: int, is_finish: bool):
	var current_pb_index = personal_best_state.data.find_custom(func(pb): return pb.identity == GameState.identity)
	var current_pb = personal_best_state.data[current_pb_index] if current_pb_index != -1 else null
	cp_split.show_split(checkpoint_text, index, time, is_finish, current_pb)

func _hide_checkpoint_time():
	cp_split.reset()

func _on_keybinds_button_pressed() -> void:
	keybinds.visible = true
	keybinds_button.visible = false

func _on_keybinds_close() -> void:
	keybinds.visible = false
	keybinds_button.visible = true

func _on_volume_slider_value_changed(value: float) -> void:
	volume_slider.value = value
	GameState.volume = value
	AudioServer.set_bus_volume_db(0, value)
