@tool
extends Node2D
class_name Menu

signal open_trigger()

@onready var high_score: HighScore = $HighScore
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rideauL: Sprite2D = $rideauL
@onready var rideauR: Sprite2D = $rideauR
@onready var banana_zone: Area2D = $rideauL/BananaZone
@onready var handle: Node2D = $Handle
@onready var menu_track: AudioStreamPlayer2D = $MenuTrackPlayer

const BANANA_START_POS = Vector2(420.0, 400.0)
const BANANA_END_POS = Vector2(430.0, -200.0)
const BPM := 135
const BEATS_PER_BAR := 4


var started := false

func reset() -> void:
	started = false
	high_score.visible = true
	pass

func open() -> void:
	_animate_banana_out()
	# Wait for next bar (4 beats), then start game
	_wait_for_loop_then_start_game()

func _wait_for_loop_then_start_game() -> void:
	# Wait until playback reaches the next bar boundary (4 beats at 135 BPM)
	var seconds_per_beat := 60.0 / float(BPM)
	var bar_duration := BEATS_PER_BAR * seconds_per_beat
	var pos := menu_track.get_playback_position()
	var next_bar_time: float = (floor(pos / bar_duration) + 1.0) * bar_duration
	var time_until_bar: float = next_bar_time - pos
	if time_until_bar <= 0.0:
		time_until_bar = bar_duration # already past, wait next bar
	get_tree().create_timer(time_until_bar).timeout.connect(_on_bar_elapsed, CONNECT_ONE_SHOT)

func _on_bar_elapsed() -> void:
	menu_track.stop()
	menu_track.seek(0.0)
	_trigger_start_game()

func _trigger_start_game() -> void:
	%Timer.start()
	%Timer3.start()
	%TringleSound.play()
	menu_track.visible = false
	high_score.visible = false
	animation_player.play("open")
	open_trigger.emit()
	

func _on_banana_zone_entered(area: Area2D) -> void:
	# do only once 
	if started:
		return

	print("[Menu] %s entered banana zone" % area.name)
	
	if area.name == "HandleGrabbable":
		%BananaHandleSound.play()
		Global.hand_force_release_object.emit()
		open()
		

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
	#get_tree().create_timer(transition_delay).timeout.connect(_do_close)
	_do_close()

func _do_close() -> void:
	reset()
	menu_track.seek(0.0)
	menu_track.play()
	menu_track.visible = true
	animation_player.play("close")
	_animate_banana_in()


@export_tool_button("close", "Callable") var close_action: Callable:
	get: return close

func _ready() -> void:
	handle.position = BANANA_END_POS
	rideauL.position = Vector2(0.0, 0.0)
	rideauR.position = Vector2(0.0, 0.0)
	banana_zone.area_entered.connect(_on_banana_zone_entered)
	menu_track.visible = true
	_animate_banana_in()

	if not Engine.is_editor_hint():
		Global.on_end_game.connect(close)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	print("tissus")
	%TissusSound.play()

func _on_timer_3_timeout() -> void:
	%Timer2.start()
	%RouletteSound.play()

func _on_timer_2_timeout() -> void:
	%RouletteSound.stop()
