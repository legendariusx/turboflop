class_name Finish

extends Checkpoint

signal finish_entered(finish: Finish)

func _init() -> void:
	checkpoint_entered.connect(func(): finish_entered.emit(self))
