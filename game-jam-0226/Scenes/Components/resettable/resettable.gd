extends Node
class_name Resettable

var _start_position: Vector2

func _ready() -> void:
	add_to_group(&"resettables")
	var p := get_parent()
	if p is Node2D:
		_start_position = p.position
	if not Engine.is_editor_hint():
		Global.on_end_game.connect(_on_game_end)

func _on_game_end() -> void:
	var p := get_parent()
	if p is Node2D:
		var tween := p.create_tween()
		tween.tween_property(p, "position", _start_position, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.8)
