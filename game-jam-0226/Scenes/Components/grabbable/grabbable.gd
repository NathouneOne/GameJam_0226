extends Area2D
class_name Grabbable

signal grabbed(hand: Node2D)
signal released()

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
func try_release() -> bool:
	if not is_grabbed:
		return true
	is_grabbed = false
	hand_grabbing = null
	released.emit()
	return true
