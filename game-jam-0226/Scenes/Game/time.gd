extends Node2D
class_name GameTime

signal on_timer_end()

@export var START_TIME_SECONDS: float

@onready var label := $TimerLabel as Label
var remaining_time_seconds := START_TIME_SECONDS

var started := false

# BIP / screen shake window (remaining time in seconds)
const BIP_START_TIME_SECONDS := 10.5
const BIP_END_TIME_SECONDS := 4.2
const BIP_INTERVAL_SECONDS := 0.22
const SCREEN_SHAKE_DURATION_SECONDS := 0.3

var last_bip_time := 0.0

# do not update too frequently
var last_timer_update_seconds := 1.0
const TIMER_UPDATE_DEBOUNCE_SECONDS := 0.1

func on_done() -> void:
	on_timer_end.emit()
	started = false
	remaining_time_seconds = START_TIME_SECONDS
	last_bip_time = 0.0

func update_label() -> void:
	if remaining_time_seconds <= 0.0:
		label.text = "00.00"
		return
	if last_timer_update_seconds < TIMER_UPDATE_DEBOUNCE_SECONDS:
		return

	var total := remaining_time_seconds
	var seconds: int = int(total) % 60
	var hundredths: int = int((total - seconds) * 100.0)
	hundredths = clampi(hundredths, 0, 99)

	label.text = "%02d.%02d" % [seconds, hundredths]

func _on_game_start() -> void:
	started = true
	remaining_time_seconds = START_TIME_SECONDS
	last_bip_time = 0.0
	update_label()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining_time_seconds = START_TIME_SECONDS
	update_label()
	Global.on_start_game.connect(_on_game_start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not started:
		return

	# debounce updates
	last_timer_update_seconds += delta
	remaining_time_seconds -= delta

	if remaining_time_seconds <= 0:
		remaining_time_seconds = 0.0
		update_label()
		on_done()
		return

	update_label()

	var elapsed_time: float = START_TIME_SECONDS - remaining_time_seconds
	# Screen shake (bip) in the final countdown window, every interval
	if remaining_time_seconds >= BIP_END_TIME_SECONDS and remaining_time_seconds <= BIP_START_TIME_SECONDS:
		if last_bip_time == 0.0 or elapsed_time - last_bip_time >= BIP_INTERVAL_SECONDS:
			Global.camShake.emit()
			last_bip_time = elapsed_time
