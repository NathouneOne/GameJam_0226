extends Area2D
class_name Useable

signal used(useable: Useable, hand: Node2D)
signal used_on(useable: Useable, interactive: Interactive, hand: Node2D)
signal use_finished(useable: Useable, hand: Node2D, has_interacted: bool)

@export var enabled: bool = true

func _ready() -> void:
	add_to_group(&"useables")

func use(hand: Node2D) -> bool:
	if not enabled:
		print("Useable disabled: ", get_parent().name)
		return false

	used.emit(self, hand)
	print("Used: ", get_parent().name, " by ", hand.name)

	var has_interacted: bool = false
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if area is Interactive:
			var interactive: Interactive = area as Interactive
			if interactive.interact(self, hand):
				has_interacted = true
				used_on.emit(self, interactive, hand)
				print("Useable ", get_parent().name, " interacted with ", interactive.get_parent().name)

	use_finished.emit(self, hand, has_interacted)
	return has_interacted
