extends Node2D
class_name Heart

@onready var interactive: Interactive = $Interactive
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	interactive.interacted.connect(_on_interacted)

func _on_interacted(_interactive: Interactive, useable: Useable, _hand: Node2D) -> void:
	print("COEUR INTERACTED")
	var is_ok: bool = false
	if useable != null:
		var source: Node = useable.get_parent()
		if source is Defibrillator:
			is_ok = true

	if is_ok:
		flash_feedback.flash_ok()
		print("Heart feedback: OK")
	else:
		flash_feedback.flash_not_ok()
		print("Heart feedback: NOT OK")
