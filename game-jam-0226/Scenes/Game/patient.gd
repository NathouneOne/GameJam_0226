@tool
extends Node2D
class_name Patient

signal patient_done()

## Preset -> list of enabled minigame keys. Keys must match exact child node names (e.g. Coeur1, Coeur2).
const PRESET_GAMES := {
	#PatientPreset.COEUR_1: ["Coeur1"],
	#PatientPreset.COEUR_2: ["Coeur2"],
	#PatientPreset.COEUR_1_AND_2: ["Coeur1", "Coeur2"],
	"PLAIE": ["Plaie"],
	#PatientPreset.ALL: ["Coeur1", "Coeur2"],
}

var _game_nodes: Dictionary = {} # populated in _ready
var _enabled_keys: Array = []
var _completed_keys: Dictionary = {}
var _minigame_done_callables: Dictionary = {} # key -> Callable, for disconnect

func _on_minigame_done(key: String) -> void:
	_completed_keys[key] = true
	if _enabled_keys.size() > 0 and _completed_keys.size() >= _enabled_keys.size():
		patient_done.emit()

func load_preset(preset: String) -> void:
	# Ensure nodes are resolved (e.g. when PRESET changes in editor before _ready)
	if _game_nodes.is_empty():
		_game_nodes = _get_game_nodes()
	# Start with all minigames disabled and invisible
	for key in _game_nodes:
		var node: Node = _game_nodes[key]
		if node:
			node.visible = false
			node.process_mode = PROCESS_MODE_DISABLED
	# Disconnect previous minigame_done subscriptions
	for key in _minigame_done_callables:
		var node: Node = _game_nodes.get(key)
		if node and node.has_signal("minigame_done") and node.is_connected("minigame_done", _minigame_done_callables[key]):
			node.disconnect("minigame_done", _minigame_done_callables[key])
	_minigame_done_callables.clear()
	_completed_keys.clear()

	_enabled_keys = PRESET_GAMES.get(preset, [])
	for key in _game_nodes:
		var node: Node = _game_nodes[key]
		if node:
			var enabled: bool = key in _enabled_keys
			node.visible = enabled
			node.process_mode = PROCESS_MODE_INHERIT if enabled else PROCESS_MODE_DISABLED
			# Subscribe to completion only when enabled
			if enabled and node.has_signal("minigame_done"):
				var callable := _on_minigame_done.bind(key)
				node.connect("minigame_done", callable)
				_minigame_done_callables[key] = callable
	# Refresh editor viewport so visibility updates are shown
	if Engine.is_editor_hint():
		queue_redraw()
		for key in _game_nodes:
			var n: Node = _game_nodes[key]
			if n is CanvasItem:
				(n as CanvasItem).queue_redraw()

var _preset: PatientPreset = PatientPreset.ALL
@export var PRESET: PatientPreset = PatientPreset.ALL:
	get:
		return _preset
	set(v):
		_preset = v
		load_preset(v)

# Getter ensures the Callable is resolved when the button is used (avoids Nil at editor load).
@export_tool_button("Emit patient_done", "Callable") var emit_patient_done_action: Callable:
	get: return _editor_emit_patient_done

func _editor_emit_patient_done() -> void:
	print("[Patient] Patient done !")
	patient_done.emit()

func _get_game_nodes() -> Dictionary:
	var out: Dictionary = {}
	for arr in PRESET_GAMES.values():
		for node_name in arr:
			if node_name not in out and has_node(node_name):
				out[node_name] = get_node(node_name)
	return out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_game_nodes = _get_game_nodes()
	load_preset(PRESET)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
