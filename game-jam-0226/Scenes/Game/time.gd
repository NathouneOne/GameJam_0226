extends Node2D
class_name GameTime

signal on_timer_end()

@export var START_TIME_SECONDS: float

@onready var label := $TimerLabel as Label
var remaining_time_seconds := START_TIME_SECONDS

var started := false


# do not update too frequently
var last_timer_update_seconds := 1.0
const TIMER_UPDATE_DEBOUNCE_SECONDS := 0.1

func on_done() -> void:
	on_timer_end.emit()
	started = false
	remaining_time_seconds = START_TIME_SECONDS

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
