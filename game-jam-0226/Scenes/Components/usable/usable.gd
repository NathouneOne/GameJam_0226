extends Area2D
class_name Useable

## Emitted when this useable is used. [param owner] is the parent node (the object being used). [param target] is the interactive's parent, or null if used in hand / no target.
signal used(owner: Node2D, target: Node2D, hand: Node2D)

@export var enabled: bool = true

func _ready() -> void:
	add_to_group(&"useables")

func use(hand: Node2D) -> bool:
	if not enabled:
		print("Useable disabled: ", get_parent().name)
		return false
	var owner_node: Node2D = get_parent() as Node2D
	var target_node: Node2D = null
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if area is Interactive:
			var interactive: Interactive = area as Interactive
			if interactive.interact(self, hand):
				target_node = interactive.get_parent() as Node2D
				print("Useable ", owner_node.name, " interacted with ", target_node.name)
				break
	if target_node == null:
		print("Used: ", owner_node.name, " by ", hand.name)
	print("[Useable] emitting used owner=", owner_node.name, " target=", target_node.name if target_node else "null", " useable_id=", get_instance_id())
	used.emit(owner_node, target_node, hand)
	return target_node != null
