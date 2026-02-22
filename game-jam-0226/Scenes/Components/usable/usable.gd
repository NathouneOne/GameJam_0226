extends Area2D
class_name Useable

## Emitted once per target when use starts (button pressed). [param target] is that interactive's parent. Kept for backwards compatibility; listeners like Scalpel receive one call per hit target.
signal use_start(owner: Node2D, target: Node2D, hand: Node2D)
## Emitted once per use with all targets hit this use. Use this when logic depends on the full set (e.g. zap if any heart). Does not replace use_start.
signal use_started(owner: Node2D, targets: Array[Node2D], hand: Node2D)
## Emitted when use stops (button released or object dropped). [param target] is the same as when use_start was called.
signal use_stop(owner: Node2D, target: Node2D, hand: Node2D)

@export var enabled: bool = true

var _use_hand: Node2D = null
var _use_targets: Array[Node2D] = [] # all interactives we started interacting with

func _ready() -> void:
	add_to_group(&"useables")
	# Detect overlapping areas on all collision layers (hitboxes at any layer)
	collision_mask = 0xFFFFFFFF

func use(hand: Node2D) -> bool:
	if not enabled:
		return false
	var owner_node: Node2D = get_parent() as Node2D
	_use_targets.clear()
	var areas: Array[Area2D] = get_overlapping_areas()
	# Build full context for this use (all overlapping interactives' parents) so listeners can decide from context (e.g. Plaie: no damage if Heart was also hit).
	var all_targets_this_use: Array[Node2D] = []
	for area: Area2D in areas:
		if area is Interactive:
			var target_node: Node2D = (area as Interactive).get_parent() as Node2D
			if target_node != null and all_targets_this_use.find(target_node) < 0:
				all_targets_this_use.append(target_node)
	# Always emit so listeners can react to "use with no valid target" (e.g. defibrillator smoke when not on heart).
	use_started.emit(owner_node, all_targets_this_use, hand)
	for area: Area2D in areas:
		if area is Interactive:
			var interactive: Interactive = area as Interactive
			var ok: bool = interactive.interact(self, hand, all_targets_this_use)
			var target_node: Node2D = interactive.get_parent() as Node2D
			if ok:
				_use_targets.append(target_node)
				use_start.emit(owner_node, target_node, hand)
	_use_hand = hand
	return _use_targets.size() > 0

func stop_use(hand: Node2D) -> void:
	var owner_node: Node2D = get_parent() as Node2D
	var targets: Array[Node2D] = _use_targets.duplicate()
	_use_hand = null
	_use_targets.clear()
	for target: Node2D in targets:
		use_stop.emit(owner_node, target, hand)
		for child: Node in target.get_children():
			if child is Interactive:
				(child as Interactive).stop_interact(hand)
				break
