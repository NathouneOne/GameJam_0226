extends Area2D
class_name Interactive

## Emitted when interaction starts (use started on this interactive).
## [param targets_for_use] is the full list of targets hit this use (same for all interactives in this use); use it to decide from context (e.g. Plaie: no damage if Heart is in the list).
signal interact_start(target: Node2D, source: Node2D, hand: Node2D, targets_for_use: Array[Node2D])
## Emitted when interaction stops (use stopped that had started on this interactive).
signal interact_stop(target: Node2D, source: Node2D, hand: Node2D)

@export var enabled: bool = true

var _interact_source: Node2D = null
var _interact_hand: Node2D = null

func _ready() -> void:
	add_to_group(&"interactives")

func interact(useable: Useable, hand: Node2D, targets_for_use: Array[Node2D] = []) -> bool:
	var target_node: Node2D = get_parent() as Node2D
	if not enabled:
		return false
	var source_node: Node2D = null
	if useable != null and useable.get_parent() is Node2D:
		source_node = useable.get_parent() as Node2D
	_interact_source = source_node
	_interact_hand = hand
	interact_start.emit(target_node, source_node, hand, targets_for_use)
	return true

func stop_interact(hand: Node2D) -> void:
	var target_node: Node2D = get_parent() as Node2D
	var source: Node2D = _interact_source
	_interact_source = null
	_interact_hand = null
	interact_stop.emit(target_node, source, hand)
