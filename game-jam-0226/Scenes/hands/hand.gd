extends Node2D

var closed: bool

enum HAND_TYPE {
	LEFT,
	RIGHT
}
@export var hand_type: HAND_TYPE = HAND_TYPE.LEFT
@export var move_speed: float = 400.0


## Returns the keymap prefix for the current hand (e.g. "leftHand_" or "rightHand_").
func keymap_key(key: String) -> String:
	return "leftHand_" + key if hand_type == HAND_TYPE.LEFT else "rightHand_" + key

func _ready() -> void:
	closed = false;


func _process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis(keymap_key("left"), keymap_key("right")),
		Input.get_axis(keymap_key("top"), keymap_key("bot"))
	)
	position += direction * move_speed * delta
