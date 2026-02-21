@tool
extends Node
class_name FlashFeedback

@export var target_node: Node2D
@export var flash_color: Color = Color(0.55, 1.0, 0.55, 1.0)
@export var flash_duration: float = 0.4
@export var pulse_scale: float = 1.12
@export var label_offset: Vector2 = Vector2(-65, -160):
	set(value):
		_label_offset = value
		if _status_label != null:
			_status_label.position = value
	get:
		return _label_offset
@export var label_font_size: int = 44
@export var text: String = ""

var _label_offset: Vector2 = Vector2(-65, -160)
var _feedback_tweens: Array[Tween] = []
var _status_label: Label = null
var _base_scale: Vector2 = Vector2.ONE

@export var animation: Node
@export var animation_name: String

func _ready() -> void:
	if target_node == null:
		return

	_base_scale = target_node.scale
	_status_label = Label.new()
	_status_label.text = ""
	_status_label.modulate = Color(1, 1, 1, 0)
	_status_label.position = label_offset
	_status_label.z_index = 20
	_status_label.add_theme_font_size_override("font_size", label_font_size)
	target_node.add_child.call_deferred(_status_label)
	
	
func flash() -> void:
	if target_node == null or _status_label == null:
		push_error("Flash triggered without target: %s or label: %s" % [target_node, _status_label])
		return
		
	print("Flash triggered !")

	# Full animation: pulse up (0.35*d), hold at pulse (0.65*d), scale back (0.65*d) = 1.65*d total
	var total_duration := flash_duration * 1.65

	target_node.modulate = flash_color
	_status_label.text = text
	_status_label.modulate = flash_color

	for t in _feedback_tweens:
		if is_instance_valid(t):
			t.kill()
	_feedback_tweens.clear()

	# Scale: pulse up, hold at pulse, then back down — same total length as color
	var scale_tween := create_tween()
	scale_tween.tween_property(target_node, "scale", _base_scale * pulse_scale, flash_duration * 0.35)
	scale_tween.tween_property(target_node, "scale", _base_scale * pulse_scale, flash_duration * 0.65) # hold at pulse
	scale_tween.tween_property(target_node, "scale", _base_scale, flash_duration * 0.65)
	_feedback_tweens.append(scale_tween)

	# Color lerps from flash_color back to white over the whole animation (smooth sine ease)
	var color_tween := create_tween()
	color_tween.set_parallel(true)
	color_tween.tween_property(target_node, "modulate", Color(1, 1, 1, 1), total_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	color_tween.tween_property(_status_label, "modulate", Color(flash_color.r, flash_color.g, flash_color.b, 0.0), total_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_feedback_tweens.append(color_tween)

# Getter ensures the Callable is resolved when the button is used (avoids Nil at editor load).
@export_tool_button("Flash", "Callable") var flash_action: Callable:
	get: return flash
