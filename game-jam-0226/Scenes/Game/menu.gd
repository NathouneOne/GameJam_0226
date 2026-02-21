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


var started := false

func reset() -> void:
	started = false
	high_score.visible = true
	pass

func open() -> void:
	_animate_banana_out()
	# Wait for the current loop to finish, then start game (chain sounds)
	_wait_for_loop_then_start_game()

func _wait_for_loop_then_start_game() -> void:
	var stream := menu_track.stream
	if not stream:
		_trigger_start_game()
		return
	var stream_length := stream.get_length()
	if stream_length <= 0.0:
		_trigger_start_game()
		return
	var pos := menu_track.get_playback_position()
	# Time until end of current loop (works whether position wraps or not)
	var pos_in_loop := pos if pos <= stream_length else fmod(pos, stream_length)
	var time_left := stream_length - pos_in_loop
	if time_left <= 0.05:
		# Already at or past loop end
		_trigger_start_game()
		return
	get_tree().create_timer(time_left).timeout.connect(_on_menu_loop_end, CONNECT_ONE_SHOT)

func _on_menu_loop_end() -> void:
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
