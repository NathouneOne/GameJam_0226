@tool
extends Node
class_name FlashFeedback

@export var target_sprite_path: NodePath = NodePath("../Sprite2D")
@export var flash_color: Color = Color(0.55, 1.0, 0.55, 1.0)
@export var flash_duration: float = 0.55
@export var pulse_scale: float = 1.12
@export var label_offset: Vector2 = Vector2(-65, -160)
@export var label_font_size: int = 44
@export var text: String = ""

var _feedback_tween: Tween = null
var _status_label: Label = null
var _sprite: Sprite2D = null
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	_sprite = get_node_or_null(target_sprite_path) as Sprite2D
	if _sprite == null:
		return

	_base_scale = _sprite.scale
	_status_label = Label.new()
	_status_label.text = ""
	_status_label.modulate = Color(1, 1, 1, 0)
	_status_label.position = label_offset
	_status_label.z_index = 20
	_status_label.add_theme_font_size_override("font_size", label_font_size)
	get_parent().add_child.call_deferred(_status_label)


@export_tool_button("Flash", "Callable") var _flash: Callable = Callable(self, "flash")

func flash() -> void:
	if _sprite == null or _status_label == null:
		return

	_sprite.modulate = flash_color
	_status_label.text = text
	_status_label.modulate = flash_color

	if _feedback_tween != null:
		_feedback_tween.kill()

	_feedback_tween = create_tween()
	_feedback_tween.parallel().tween_property(_sprite, "modulate", Color(1, 1, 1, 1), flash_duration)
	_feedback_tween.parallel().tween_property(_sprite, "scale", _base_scale * pulse_scale, flash_duration * 0.35)
	_feedback_tween.parallel().tween_property(_status_label, "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 0.0), flash_duration)
	_feedback_tween.tween_property(_sprite, "scale", _base_scale, flash_duration * 0.65)
