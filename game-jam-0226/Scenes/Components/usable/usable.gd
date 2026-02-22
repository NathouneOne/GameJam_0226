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
	print("[Useable] use() owner=%s overlapping_areas=%d" % [owner_node.name, areas.size()])
	for i: int in range(areas.size()):
		var area: Area2D = areas[i]
		var parent_name: String = String(area.get_parent().name) if area.get_parent() else "?"
		var is_interactive: bool = area is Interactive
		print("[Useable]   [%d] area=%s parent=%s is_interactive=%s" % [i, area.name, parent_name, is_interactive])
		if area is Interactive:
			var interactive: Interactive = area as Interactive
			var ok: bool = interactive.interact(self, hand)
			var target_node: Node2D = interactive.get_parent() as Node2D
			var target_class: String = target_node.get_class() if target_node else "?"
			var tn_name: String = String(target_node.name) if target_node else "null"
			print("[Useable]   -> interact()=%s target=%s (class=%s)" % [ok, tn_name, target_class])
			if ok:
				_use_targets.append(target_node)
				use_start.emit(owner_node, target_node, hand)
	var target_names: Array[String] = []
	for t: Node2D in _use_targets:
		target_names.append("%s(%s)" % [t.name, t.get_class()])
	print("[Useable] _use_targets=%s -> emitting use_started" % [str(target_names)])
	if _use_targets.size() > 0:
		use_started.emit(owner_node, _use_targets, hand)
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
