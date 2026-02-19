extends Node2D
class_name Defibrillator

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	print("[Defibrilateur] _ready name=", name, " useable=", useable, " useable_id=", useable.get_instance_id() if useable else 0)
	useable.used.connect(_on_used)
	print("[Defibrilateur] connected to useable.used")

func _on_used(_owner: Node2D, target: Node2D, _hand: Node2D) -> void:
	print("[Defibrilateur] _on_used CALLED owner=", _owner.name if _owner else "null", " target=", target.name if target else "null")
	if target is Heart:
		flash_feedback.flash_ok()
		print("Defibrillator feedback: OK")
	else:
		flash_feedback.flash_not_ok()
		print("Defibrillator feedback: NOT OK")
