class_name CPSplit

extends CenterContainer

@onready var personal_best: Label = $HBoxContainer/PersonalBest
@onready var checkpoint_label: Label = $HBoxContainer/PanelContainer/Container/Checkpoint/Label
@onready var time_label: Label = $HBoxContainer/PanelContainer/Container/Time
@onready var difference: PanelContainer = $HBoxContainer/PanelContainer/Container/Difference
@onready var difference_label: Label = $HBoxContainer/PanelContainer/Container/Difference/Label
@onready var timer: Timer = $Timer

func _ready():
	reset_size()

func show_split(checkpoint_text: String, index: int, time: int, is_finish: bool, pb: PersonalBest = null):
	visible = true
	var is_pb := not pb
	if pb and index < pb.checkpoint_times.size():
		difference.visible = true
		
		var difference_ms = time - pb.checkpoint_times[index]
		var label_text = "%s"
		var style = difference.get("theme_override_styles/panel") as StyleBoxFlat
		if difference_ms > 0:
			style.bg_color = Color("ea4f49")
			label_text = "+" + label_text
		elif difference_ms < 0:
			style.bg_color = Color("0856a0")
			label_text = "-" + label_text
			is_pb = true
		else:
			style.bg_color = Color("6b6a6b")
			
		difference.set("theme_override_styles/panel", style)
		difference_label.text = label_text % TimeHelper.format_time_ms(abs(difference_ms))
	
	checkpoint_label.text = checkpoint_text
	time_label.text = TimeHelper.format_time_ms(time)
	reset_size()
	
	if not is_finish:
		timer.stop()
		timer.start()
	else:
		personal_best.visible = is_pb

func reset():
	visible = false
	personal_best.visible = false
	difference.visible = false

func _on_timer_timeout() -> void:
	visible = false
