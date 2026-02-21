extends Node2D

@export var fly_scene: PackedScene
@export var spawn_interval_seconds: float = 3.0
@export var spawn_interval_random_delta: float = 1.5
@export var max_alive_flies: int = 3

var _spawn_zone: SpawnZone
var _fly_zone: FlyZone
var _spawn_timer: float
var _alive_fly_count: int = 0

@onready var flyingNoise: AudioStreamPlayer2D = $FlyingNoise

func _ready() -> void:
	if fly_scene == null:
		fly_scene = preload("res://Scenes/fly/fly.tscn") as PackedScene
		print("[FlySpawner] fly_scene: ", "default" if fly_scene else "null")
	_spawn_zone = get_node_or_null("SpawnZone") as SpawnZone
	_fly_zone = get_node_or_null("FlyZone") as FlyZone
	print("[FlySpawner] _ready: SpawnZone=", _spawn_zone != null, ", FlyZone=", _fly_zone != null, ", children=", get_children().size(), " ", get_children().map(func(c): return c.name))
	if not _spawn_zone:
		push_warning("FlySpawner: No SpawnZone child found.")
	if not _fly_zone:
		push_warning("FlySpawner: No FlyZone child found.")
	_reset_spawn_timer()
	print("[FlySpawner] first spawn in ", _spawn_timer, " s")
	if not Engine.is_editor_hint():
		Global.on_end_game.connect(_on_game_end)
		Global.on_start_game.connect(_on_game_start)


func _process(delta: float) -> void:
	if not _spawn_zone:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_fly()
		_reset_spawn_timer()
		print("[FlySpawner] next spawn in ", _spawn_timer, " s")


func _reset_spawn_timer() -> void:
	_spawn_timer = spawn_interval_seconds + randf() * spawn_interval_random_delta


func _on_fly_smashed() -> void:
	_alive_fly_count = maxi(0, _alive_fly_count - 1)


var fly_sound_playing := false

func _on_game_start() -> void:
	fly_sound_playing = false
	set_process(true)

func _on_game_end() -> void:
	flyingNoise.stop()
	set_process(false)
	for child in get_children():
		if child is Fly:
			child.queue_free()
	_alive_fly_count = 0
	fly_sound_playing = false

func _spawn_fly() -> void:
	if not _fly_zone or not _spawn_zone:
		print("[FlySpawner] _spawn_fly skipped: FlyZone=", _fly_zone != null, ", SpawnZone=", _spawn_zone != null)
		return
	if _alive_fly_count >= max_alive_flies:
		return

	if not fly_sound_playing:
		flyingNoise.play()
		fly_sound_playing = true

	var fly: Node2D = fly_scene.instantiate() as Node2D
	if fly.has_signal("smashed"):
		fly.smashed.connect(_on_fly_smashed)
	var pos: Vector2 = _spawn_zone.get_random_spawn_position()
	add_child(fly)
	fly.global_position = pos
	_alive_fly_count += 1
	print("[FlySpawner] spawned fly at ", pos, " (alive: ", _alive_fly_count, " / ", max_alive_flies, ")")
	# Interacting and despawning are handled by the fly itself
