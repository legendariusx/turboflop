extends Control

const MAX_SCORES = 10

@onready var scoreboard: Tree = $Scoreboard

var personal_best_state: PersonalBestState

func _ready():
	scoreboard.set_column_title(0, "#")
	scoreboard.set_column_title(1, "Player")
	scoreboard.set_column_title(2, "Time")
	
	scoreboard.set_column_expand_ratio(0, 1)
	scoreboard.set_column_expand_ratio(1, 10)
	scoreboard.set_column_expand_ratio(2, 10)
	
	scoreboard.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	scoreboard.set_column_title_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)

func _process(_delta: float) -> void:
	scoreboard.visible = Input.is_action_pressed("show_scoreboard")

func connect_personal_best_state(u_personal_best_state: PersonalBestState):
	personal_best_state = u_personal_best_state
	personal_best_state.update.connect(_on_personal_best_updated)

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
		create_scoreboard_row(tree_root, i + 1, player_name, pb.time)

	if current_player_not_in_top:
		create_scoreboard_row(tree_root, current_player_index + 1, GameState.current_user.name + " (You)", sorted_pbs[current_player_index].time)

func create_scoreboard_row(root: TreeItem, placement: int, player_name: String, time: int):
	var new_row = scoreboard.create_item(root)
	new_row.set_text(0, str(placement))
	new_row.set_text(1, player_name) 
	new_row.set_text(2, TimeHelper.format_time_ms(time)) 
	
	new_row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	new_row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
