extends Area2D
class_name Grabbable

signal grabbed(hand: Node2D)
signal released()

## If true, the object keeps its rotation while grabbed (e.g. vertical rail handle).
@export var lock_rotation: bool = false
## If true, the object only moves on the Y axis while grabbed (e.g. vertical rail handle).
@export var position_y_only: bool = false

var is_grabbed: bool = false
var hand_grabbing: Node2D = null

func _ready() -> void:
	add_to_group(&"grabbables")


# return true if grabbed
func grab(hand: Node2D) -> bool:
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
		
	is_grabbed = false
	hand_grabbing = null
	released.emit()
	return true

func can_release() -> bool:
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if area.is_in_group(&"item_zone"):
			return true
	return false
