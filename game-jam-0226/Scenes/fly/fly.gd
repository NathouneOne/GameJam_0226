extends Node2D

## Emitted when this fly is smashed (interacted).
signal smashed

@export var fly_zone_path: NodePath
@export var move_speed: float = 165.0
@export var direction_change_interval: float = 0.4
## How much the fly's heading wobbles per second (radians). Higher = more bzzzz.
@export var wobble_strength: float = 12.0
## Random speed variation (multiplier around 1.0). More = more darting.
@export var speed_variation: float = 0.4
@export var despawn_delay_seconds: float = 0.35

var _zone: FlyZone
var _current_angle: float
var _direction_timer: float
var _interactive: Node


func _ready() -> void:
	if fly_zone_path.is_empty():
		_zone = get_parent().get_node_or_null("FlyZone") as FlyZone
	else:
		_zone = get_node_or_null(fly_zone_path) as FlyZone
	if _zone:
		_pick_new_direction()
		print("[Fly] _ready: FlyZone found, parent=", get_parent().name)
	else:
		push_warning("Fly: No FlyZone found. Set fly_zone_path or ensure a sibling node named FlyZone exists.")
		print("[Fly] _ready: NO FlyZone (parent=", get_parent().name, ", siblings=", get_parent().get_children().map(func(c): return c.name), ")")
	_interactive = get_node_or_null("Interactive")
	if _interactive and _interactive.has_signal("interact_start"):
		_interactive.interact_start.connect(_on_interact_start)


func _process(delta: float) -> void:
	if not _zone:
		return
	_direction_timer -= delta
	if _direction_timer <= 0.0:
		_pick_new_direction()
		_direction_timer = direction_change_interval
	# Wobble heading every frame so the fly doesn't move in a straight line
	_current_angle += randf_range(-wobble_strength * delta, wobble_strength * delta)
	var speed_now := move_speed * (1.0 + randf_range(-speed_variation, speed_variation))
	var velocity := Vector2.from_angle(_current_angle) * speed_now
	global_position += velocity * delta
	global_position = _zone.clamp_position(global_position)


func _pick_new_direction() -> void:
	_current_angle = randf() * TAU


func _on_interact_start(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	smashed.emit()
	var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.sprite_frames and "smash" in sprite.sprite_frames.get_animation_names():
		sprite.play("smash")
	get_tree().create_timer(despawn_delay_seconds).timeout.connect(queue_free)
	set_process(false)
	if _interactive and _interactive.has_method("set"):
		_interactive.set("enabled", false)
