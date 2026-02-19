extends Area2D
class_name Useable

## Emitted when use starts (button pressed). [param target] is the interactive's parent, or null if none.
signal use_start(owner: Node2D, target: Node2D, hand: Node2D)
## Emitted when use stops (button released or object dropped). [param target] is the same as when use_start was called.
signal use_stop(owner: Node2D, target: Node2D, hand: Node2D)

@export var enabled: bool = true

var _use_hand: Node2D = null
var _use_target: Node2D = null

func _ready() -> void:
	add_to_group(&"useables")

func use(hand: Node2D) -> bool:
	if not enabled:
		return false
	var owner_node: Node2D = get_parent() as Node2D
	var target_node: Node2D = null
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if area is Interactive:
			var interactive: Interactive = area as Interactive
			if interactive.interact(self, hand):
				target_node = interactive.get_parent() as Node2D
				break
	_use_hand = hand
	_use_target = target_node
	use_start.emit(owner_node, target_node, hand)
	return target_node != null

func stop_use(hand: Node2D) -> void:
	var owner_node: Node2D = get_parent() as Node2D
	var target: Node2D = _use_target
	_use_hand = null
	_use_target = null
	use_stop.emit(owner_node, target, hand)
	if target != null:
		for child: Node in target.get_children():
			if child is Interactive:
				(child as Interactive).stop_interact(hand)
				break
