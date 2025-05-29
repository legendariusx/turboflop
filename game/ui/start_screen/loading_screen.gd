class_name LoadingScreen

extends Control

signal play_offline
signal try_again

func show_connecting():
	$CenterContainer/VBoxContainer/ConnectionStatus.text = "Connecting..."
	$CenterContainer/VBoxContainer/ButtonContainer.visible = false

func show_connection_failed() -> void:
	$CenterContainer/VBoxContainer/ConnectionStatus.text = "Connection failed"
	$CenterContainer/VBoxContainer/ButtonContainer.visible = true

func _on_play_offline_pressed() -> void:
	play_offline.emit()

func _on_try_again_pressed() -> void:
	try_again.emit()
