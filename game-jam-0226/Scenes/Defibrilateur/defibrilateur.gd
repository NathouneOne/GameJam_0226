extends Node2D
class_name Defibrillator

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

var _used_on_heart: bool = false

func _ready() -> void:
	useable.used.connect(_on_used)
	useable.used_on.connect(_on_used_on)
	useable.use_finished.connect(_on_use_finished)

func _on_used(_useable: Useable, _hand: Node2D) -> void:
	print("defibrilateur _on_used")
	_used_on_heart = false

func _on_used_on(_useable: Useable, interactive: Interactive, _hand: Node2D) -> void:
	print("defibrilateur _on_used_on")
	var target: Node = interactive.get_parent()
	if target is Heart:
		_used_on_heart = true

func _on_use_finished(_useable: Useable, _hand: Node2D, _has_interacted: bool) -> void:
	if _used_on_heart:
		flash_feedback.flash_ok()
		print("Defibrillator feedback: OK")
	else:
		flash_feedback.flash_not_ok()
		print("Defibrillator feedback: NOT OK")
