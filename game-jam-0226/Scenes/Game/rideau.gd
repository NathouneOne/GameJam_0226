@tool
extends Sprite2D
class_name Rideau

var previous_global_position : Vector2
var smoothed_velocity := 0.0

func _ready() -> void:
	previous_global_position = global_position

func _process(delta: float) -> void:
	var current_position := global_position
	var raw_velocity := (current_position - previous_global_position) / delta

	previous_global_position = current_position

	# We only care about horizontal movement
	var horizontal_velocity := raw_velocity.x

	# Smooth it for cloth-like inertia
	smoothed_velocity = lerp(smoothed_velocity, horizontal_velocity, 8.0 * delta)

	material.set_shader_parameter("velocity", smoothed_velocity)
