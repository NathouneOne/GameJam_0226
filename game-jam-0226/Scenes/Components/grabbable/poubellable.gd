extends Area2D
class_name Poubellable

signal grabbed(hand: Node2D)
signal released()

## When true, grabbing is refused (e.g. once in poubelle or game ended).
var disabled: bool = false

var is_grabbed: bool = false
var hand_grabbing: Node2D = null

func _ready() -> void:
	add_to_group(&"grabbables")
	Global.on_end_game.connect(_on_end_game)

func _on_end_game() -> void:
	disabled = true

# return true if grabbed
func grab(hand: Node2D) -> bool:
	if disabled:
		return false
	if is_grabbed:
		return true
	is_grabbed = true
	hand_grabbing = hand
	grabbed.emit(hand)
	return true

# Returns true if released
func release() -> bool:
	if not is_grabbed:
		return true

	if not can_release():
		return false

	# Now in poubelle: no longer grabbable
	disabled = true
	is_grabbed = false
	hand_grabbing = null
	released.emit()
	return true

func can_release() -> bool:
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if area.is_in_group(&"poubelle_zone"):
			return true
	return false
