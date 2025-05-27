class_name CPSplit

extends CenterContainer

func _ready():
	reset_size()

func show_split(index: int, time: int, pb: PersonalBest = null):
	visible = true
	if pb and index < pb.checkpoint_times.size():
		$PanelContainer/Container/Difference.visible = true
		
		var difference_ms = time - pb.checkpoint_times[index]
		var label_text = "%s"
		var style = $PanelContainer/Container/Difference.get("theme_override_styles/panel") as StyleBoxFlat
		if difference_ms > 0:
			style.bg_color = Color("ea4f49")
			label_text = "+" + label_text
		elif difference_ms < 0:
			style.bg_color = Color("0856a0")
			label_text = "-" + label_text
		else:
			style.bg_color = Color("6b6a6b")
			
		$PanelContainer/Container/Difference.set("theme_override_styles/panel", style)
		$PanelContainer/Container/Difference/Label.text = label_text % TimeHelper.format_time_ms(abs(difference_ms))
		
	$PanelContainer/Container/Time.text = TimeHelper.format_time_ms(time)
	reset_size()
	
	await get_tree().create_timer(2.5).timeout
	visible = false
