extends Node
class_name Resettable

@export var override_position: Vector2

var _start_position: Vector2
var _start_rotation: float

func _ready() -> void:
	add_to_group(&"resettables")
	var p := get_parent()
	if p is Node2D:
		_start_position = p.position
		_start_rotation = p.rotation
	if not Engine.is_editor_hint():
		Global.on_end_game.connect(_on_game_end)

func _on_game_end() -> void:
	var p := get_parent()
	if p is Node2D:
		var tween := p.create_tween()
		tween.set_parallel(true)
		var target_pos := _start_position
		if override_position != null and override_position != Vector2.ZERO:
			target_pos = override_position

		tween.tween_property(p, "position", target_pos, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.8)
		tween.tween_property(p, "rotation", _start_rotation, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.8)
