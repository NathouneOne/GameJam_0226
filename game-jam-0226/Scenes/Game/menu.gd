@tool
extends Node2D
class_name Menu


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rideauL: Sprite2D = $rideauL
@onready var rideauR: Sprite2D = $rideauR
@onready var banana_zone: Area2D = $rideauL/BananaZone
@onready var handle: Node2D = $Handle

const BANANA_START_POS = Vector2(420.0, 400.0)
const BANANA_END_POS = Vector2(430.0, -200.0)

@export var transition_delay: float = 1.0


var started := false

func reset() -> void:
	started = false
	pass

func open() -> void:
	animation_player.play("open")
	%Timer.start()
	%Timer3.start()
	%TringleSound.play()
	_animate_banana_out()

func _on_banana_zone_entered(area: Area2D) -> void:
	# do only once 
	if started:
		return

	print("[Menu] %s entered banana zone" % area.name)
	
	if area.name == "HandleGrabbable":
		%BananaHandleSound.play()
		Global.hand_force_release_object.emit()
		open()
		get_tree().create_timer(transition_delay).timeout.connect(func(): Global.on_start_game.emit())

@export_tool_button("open", "Callable") var open_action: Callable:
	get: return open

func _animate_banana_in() -> void:
	handle.rotation = 0.0
	var t := create_tween()
	t.tween_interval(1.0)
	t.tween_property(handle, "position", BANANA_START_POS, 0.5).set_ease(Tween.EASE_IN)

func _animate_banana_out() -> void:
	var t := create_tween()
	t.tween_interval(0.2)
	t.tween_property(handle, "position", BANANA_END_POS, 0.5).set_ease(Tween.EASE_IN)

func close() -> void:
	get_tree().create_timer(transition_delay).timeout.connect(_do_close)

func _do_close() -> void:
	reset()
	animation_player.play("close")
	_animate_banana_in()


@export_tool_button("close", "Callable") var close_action: Callable:
	get: return close

func _ready() -> void:
	handle.position = BANANA_END_POS
	rideauL.position = Vector2(0.0, 0.0)
	rideauR.position = Vector2(0.0, 0.0)
	banana_zone.area_entered.connect(_on_banana_zone_entered)
	_animate_banana_in()

	if not Engine.is_editor_hint():
		Global.on_end_game.connect(close)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	%TissusSound.play()

func _on_timer_3_timeout() -> void:
	%Timer2.start()
	%RouletteSound.play()

func _on_timer_2_timeout() -> void:
	%RouletteSound.stop()
