extends Node2D
class_name Defibrillator

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	useable.use_start.connect(_on_use_start)
	useable.use_stop.connect(_on_use_stop)

func _on_use_start(_owner: Node2D, target: Node2D, _hand: Node2D) -> void:
	if target is Heart:
		flash_feedback.flash_ok()
	else:
		flash_feedback.flash_not_ok()

func _on_use_stop(_owner: Node2D, _target: Node2D, _hand: Node2D) -> void:
	pass
