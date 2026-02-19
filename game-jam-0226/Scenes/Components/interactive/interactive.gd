extends Area2D
class_name Interactive

signal interacted(interactive: Interactive, useable: Useable, hand: Node2D)

@export var enabled: bool = true

func _ready() -> void:
	add_to_group(&"interactives")

func interact(useable: Useable, hand: Node2D) -> bool:
	if not enabled:
		print("Interactive disabled: ", get_parent().name)
		return false

	interacted.emit(self, useable, hand)
	var source_name: String = "empty_hand"
	if useable != null and useable.get_parent() != null:
		source_name = useable.get_parent().name
	print("Interacted: ", get_parent().name, " from ", source_name, " by ", hand.name)

	return true
