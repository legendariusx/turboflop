class_name Finish

extends Checkpoint

signal finish_entered

func _init() -> void:
	checkpoint_entered.connect(func(): finish_entered.emit())
