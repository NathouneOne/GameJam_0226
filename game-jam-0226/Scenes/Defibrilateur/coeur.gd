extends Node2D
class_name Heart

@onready var interactive: Interactive = $Interactive
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	print("[Coeur] _ready name=", name, " interactive=", interactive, " interactive_id=", interactive.get_instance_id() if interactive else 0)
	interactive.interacted.connect(_on_interacted)
	print("[Coeur] connected to interactive.interacted")

func _on_interacted(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	print("[Coeur] _on_interacted CALLED target=", _target.name if _target else "null", " source=", source.name if source else "null")
	print("Heart interacted with: ", source.name if source else "null")
	var is_ok: bool = source is Defibrillator
	if is_ok:
		flash_feedback.flash_ok()
		print("Heart feedback: OK")
	else:
		flash_feedback.flash_not_ok()
		print("Heart feedback: NOT OK")
