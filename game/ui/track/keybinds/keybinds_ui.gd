extends VBoxContainer

var keybinds: Array[Keybind] = [
		Keybind.new(
			&"Accelerate",
			&"W, Up",
			&"A, RT"
		),
		Keybind.new(
			&"Reverse",
			&"S, Down",
			&"LT"
		),
		Keybind.new(
			&"Steer",
			&"A, D, Left, Right",
			&"LS"
		),
		Keybind.new(
			&"Boost",
			&"F",
			&"LB"
		),
		Keybind.new(
			&"Respawn",
			&"R",
			&"X"
		),
		Keybind.new(
			&"Reset",
			&"Backspace",
			&"Select"
		),
		Keybind.new(
			&"Scoreboard",
			&"TAB",
			&"RB"
		),
		Keybind.new(
			&"Back to main menu",
			&"Esc",
			&"Start"
		),
		Keybind.new(
			&"Change opponent visibility",
			&"O",
			&"Y"
		),
		Keybind.new(
			&"Change camera",
			&"C",
			&"D-Pad Up"
		),
	]

signal close

@onready var keybinds_container = $KeybindsContainer

func _ready():
	keybinds_container.set_column_title(0, "Action")
	keybinds_container.set_column_title(1, "Keyboard")
	keybinds_container.set_column_title(2, "Gamepad")
	
	keybinds_container.set_column_expand_ratio(0, 5)
	keybinds_container.set_column_expand_ratio(1, 1)
	keybinds_container.set_column_expand_ratio(2, 1)
	
	var root = keybinds_container.create_item()
	
	for keybind in keybinds:
		_render_keybind(keybind, root)
		
	reset_size()
	keybinds_container.reset_size()

func _render_keybind(keybind: Keybind, root: TreeItem):
	var new_row = keybinds_container.create_item(root)
	new_row.set_text(0, keybind.keybind_name)
	new_row.set_text(1, keybind.keyboard_bindings)
	new_row.set_text(2, keybind.controller_bindings)

class Keybind:
	var keybind_name: String
	var keyboard_bindings: String
	var controller_bindings: String
	
	func _init(u_keybind_name: String, u_keyboard_bindings: String, u_controller_bindings: String):
		keybind_name = u_keybind_name
		keyboard_bindings = u_keyboard_bindings
		controller_bindings = u_controller_bindings


func _on_button_pressed() -> void:
	close.emit()
