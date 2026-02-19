extends Node

class_name Grabbable

signal grabbed(hand: Node2D)
signal released()

var is_grabbed: bool = false
var hand_grabbing: Node2D = null

func _ready() -> void:
	add_to_group(&"grabbables")

func grab(hand: Node2D) -> void:
	if is_grabbed:
		return
	is_grabbed = true
	hand_grabbing = hand
	grabbed.emit(hand)

func release() -> void:
	if not is_grabbed:
		return
	is_grabbed = false
	hand_grabbing = null
	released.emit()
