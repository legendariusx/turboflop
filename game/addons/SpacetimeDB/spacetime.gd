@tool
extends EditorPlugin

const AUTOLOAD_NAME := "SpacetimeDB"
const AUTOLOAD_PATH := "res://addons/SpacetimeDB/Core/SpacetimeDBClient.gd"

func _enter_tree():
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		get_editor_interface().get_resource_filesystem().scan()
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree():
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)
