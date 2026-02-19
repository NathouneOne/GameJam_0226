extends Node2D

var closed: bool

enum HAND_TYPE {
	LEFT,
	RIGHT
}
@export var hand_type: HAND_TYPE = HAND_TYPE.LEFT
@export var move_speed: float = 400.0

var grabbed_object: Node2D = null
var grabbable_component: Grabbable = null

@onready var area_2d: Area2D = $Area2D


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
	_process_grabbed_object()
	
	if Input.is_action_just_pressed(keymap_key("action")):
		if grabbed_object:
			_release_object()
		else:
			_try_grab_object()

func _try_grab_object() -> void:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	for area: Area2D in areas:
		var target: Node = area.get_parent()
		if target is Node2D:
			# Find a child that is in the "grabbables" group
			for child: Node in target.get_children():
				if child is Grabbable:
					_grab_object(target as Node2D, child as Grabbable)
					return

func _grab_object(object: Node2D, component: Grabbable) -> void:
	grabbed_object = object
	grabbable_component = component
	grabbable_component.grab(self)

func _release_object() -> void:
	if grabbable_component:
		grabbable_component.release()
	
	grabbed_object = null
	grabbable_component = null

func _process_grabbed_object() -> void:
	if grabbed_object:
		grabbed_object.global_position = global_position
