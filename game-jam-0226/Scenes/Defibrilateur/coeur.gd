extends Node2D
class_name Heart

@onready var interactive: Interactive = $Interactive
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	interactive.interact_start.connect(_on_interact_start)
	interactive.interact_stop.connect(_on_interact_stop)

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	var is_ok: bool = source is Defibrillator
	if is_ok:
		flash_feedback.flash_ok()
	else:
		flash_feedback.flash_not_ok()

func _on_interact_stop(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	pass
