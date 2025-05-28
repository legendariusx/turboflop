class_name TrackUI

extends Control

const MAX_SCORES = 10

@onready var countdown: Label = $Countdown
@onready var timer: Label = $Timer
@onready var scoreboard: Tree = $Scoreboard
@onready var cp_times: Tree = $CheckpointTimes
@onready var cp_split: CPSplit = $CPSplit

var personal_best_state: PersonalBestState
var cp_tree_root: TreeItem

func _ready():
	# parent has to be Track in order to connect relevant signals
	assert(get_parent() is Track, "parent of TrackUI has to be of type Track")
	
	var parent: Track = get_parent()
	if not parent.is_node_ready(): await parent.ready
	
	parent.finished.connect(_on_finished)
	personal_best_state = parent.personal_best_state
	personal_best_state.update.connect(_on_personal_best_updated)
	
	scoreboard.set_column_title(0, "#")
	scoreboard.set_column_title(1, "Player")
	scoreboard.set_column_title(2, "Time")
	
	scoreboard.set_column_expand_ratio(0, 1)
	scoreboard.set_column_expand_ratio(1, 10)
	scoreboard.set_column_expand_ratio(2, 10)
	
	scoreboard.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	
	cp_times.set_column_title(0, "#")
	cp_times.set_column_title(1, "Time")
	
	cp_times.set_column_expand_ratio(0, 1)
	cp_times.set_column_expand_ratio(1, 2)

func _process(_delta: float) -> void:
	scoreboard.visible = Input.is_action_pressed("show_scoreboard")

func reset():
	cp_times.clear()
	cp_tree_root = cp_times.create_item()

func on_checkpoint_entered(index: int, time: int):
	_add_checkpoint_label("%02d" % index, time)
	_show_checkpoint_time(index, time)

func _on_finished(time: int):
	_add_checkpoint_label("🏁", time)
	_show_checkpoint_time((get_parent() as Track).checkpoint_times.size() - 1, time)

func _on_personal_best_updated(_row: PersonalBest):
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
		_create_scoreboard_row(tree_root, i + 1, player_name, pb.time)

	if current_player_not_in_top:
		_create_scoreboard_row(tree_root, current_player_index + 1, GameState.current_user.name + " (You)", sorted_pbs[current_player_index].time)

func _create_scoreboard_row(root: TreeItem, placement: int, player_name: String, time: int):
	var new_row = scoreboard.create_item(root)
	new_row.set_text(0, str(placement))
	new_row.set_text(1, player_name) 
	new_row.set_text(2, TimeHelper.format_time_ms(time)) 
	
	new_row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)

func _add_checkpoint_label(number: String, time: int) -> void:
	var new_row = cp_times.create_item(cp_tree_root)
	new_row.set_text(0, number)
	new_row.set_text(1, TimeHelper.format_time_ms(time))
	
	new_row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

func _show_checkpoint_time(index: int, time: int):
	var current_pb_index = personal_best_state.data.find_custom(func(pb): return pb.identity == GameState.identity)
	var current_pb = personal_best_state.data[current_pb_index] if current_pb_index != -1 else null
	cp_split.show_split(index, time, current_pb)
