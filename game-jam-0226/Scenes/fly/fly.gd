extends Node2D
class_name Fly

## Emitted when this fly is smashed (interacted).
signal smashed

@export var fly_zone_path: NodePath
@export var move_speed: float = 165.0
@export var direction_change_interval: float = 1.8
## How much the fly's heading wobbles per second (radians). Higher = more bzzzz.
@export var wobble_strength: float = 3.0
## Random speed variation (multiplier around 1.0). More = more darting.
@export var speed_variation: float = 0.15
@export var despawn_delay_seconds: float = 0.35
## Max tilt in degrees (slight rotation when flying up/down).
@export var max_tilt_degrees: float = 30.0

@export var fly_success_points: int = 33

var _zone: FlyZone
var _current_angle: float
var _direction_timer: float
var alive := true

@onready var interactive: Interactive = $Interactive
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var smashNoise: AudioStreamPlayer2D = $SmashNoise


func _ready() -> void:
	sprite.play("fly")
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
	interactive.interact_start.connect(_on_interact_start)


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
	var new_pos := global_position + velocity * delta
	var clamped_pos := _zone.clamp_position(new_pos)
	# If we hit the boundary, bounce off (reflect direction) instead of sticking
	if new_pos.distance_to(clamped_pos) > 0.5:
		var outward_normal := (new_pos - clamped_pos).normalized()
		var bounced := velocity.bounce(outward_normal)
		_current_angle = bounced.angle()
	global_position = clamped_pos
	# Mirror on X when flying left so the fly faces movement direction
	scale.x = -1.0 if cos(_current_angle) >= 0.0 else 1.0
	# Slight tilt (a few degrees) based on vertical movement
	rotation = sin(_current_angle) * deg_to_rad(max_tilt_degrees)


func _pick_new_direction() -> void:
	_current_angle = randf() * TAU


func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	if source != null:
		# only smash via hand for now
		return
		
	if not alive:
		return

	alive = false
	smashed.emit()
	sprite.play("smash")
	smashNoise.play()
	if despawn_delay_seconds > 0:
		get_tree().create_timer(despawn_delay_seconds).timeout.connect(queue_free)
	
	Global.camShake.emit()

	# Delay points a bit not to clash with the audio
	get_tree().create_timer(0.25).timeout.connect(
		func() -> void:
			Global.on_add_score.emit(fly_success_points)
	)
	
	set_process(false)
	interactive.enabled = false
