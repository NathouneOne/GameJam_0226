@tool
extends Node2D
class_name Game

@onready var patient: Patient = $Patient
@onready var animation_player: AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	patient.patient_done.connect(_on_patient_done)

func _on_patient_done() -> void:
	print("[Game] Patient done !")
	# on out finished, 
	animation_player.animation_finished.connect(
		func (animation_name: String) -> void:
			if animation_name == "patient_out":
				_enter_new_patient()
	)
	animation_player.play("patient_out")



func _enter_new_patient() -> void:
	# Swap patient, pick a random preset
	# TODO: better progression logic
	var preset: Patient.PatientPreset = Patient.PatientPreset.values().pick_random()
	# Played backwards as I did not find how to invert 
	patient.PRESET = preset
	animation_player.play_backwards("patient_in")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
