extends Area2D
class_name Interactive

## Emitted when this interactive is interacted with. [param target] is this interactive's parent, [param source] is the useable's parent (or null if empty hand).
signal interacted(target: Node2D, source: Node2D, hand: Node2D)

@export var enabled: bool = true

func _ready() -> void:
	add_to_group(&"interactives")

func interact(useable: Useable, hand: Node2D) -> bool:
	if not enabled:
		print("Interactive disabled: ", get_parent().name)
		return false

	var target_node: Node2D = get_parent() as Node2D
	var source_node: Node2D = null
	if useable != null and useable.get_parent() is Node2D:
		source_node = useable.get_parent() as Node2D
	var source_name: String = source_node.name if source_node else "empty_hand"
	print("[Interactive] emitting interacted target=", target_node.name, " source=", source_name, " interactive_id=", get_instance_id())
	interacted.emit(target_node, source_node, hand)
	print("Interacted: ", target_node.name, " from ", source_name, " by ", hand.name)
	return true
