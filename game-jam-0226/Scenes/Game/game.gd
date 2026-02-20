@tool
extends Node2D
class_name Game

@onready var patient: Patient = $Patient
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_time: GameTime = $GameTime

enum GameStateEnum {
	MENU,
	IN_GAME,
}

var game_state := GameStateEnum.IN_GAME

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	patient.patient_done.connect(_on_patient_done)
	game_time.on_timer_end.connect(_on_timer_end)

	# hack to have the patient out at the start
	animation_player.play("patient_out")
	
	if not Engine.is_editor_hint():
		Global.on_start_game.connect(_on_game_start)


func _on_game_start() -> void:
	print("[Game] on game start !")
	_enter_new_patient()

func _on_patient_done() -> void:
	print("[Game] Patient done !")
	# on out finished, 
	animation_player.animation_finished.connect(
		func(animation_name: String) -> void:
			if not game_state == GameStateEnum.IN_GAME:
				return

			if animation_name == "patient_out":
				_enter_new_patient()
	)
	animation_player.play("patient_out")


func _on_timer_end() -> void:
	animation_player.play("patient_out")
	game_state = GameStateEnum.MENU
	Global.on_end_game.emit()

func _enter_new_patient() -> void:
	# Swap patient, pick a random preset
	# TODO: better progression logic
	var preset: Patient.PatientPreset = Patient.PatientPreset.values().pick_random()
	# Played backwards as I did not find how to invert 
	patient.PRESET = preset
	animation_player.play_backwards("patient_in")
	
	if not Engine.is_editor_hint():
		Global.on_new_patient.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
