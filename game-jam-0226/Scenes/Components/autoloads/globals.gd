@tool
extends Node

signal on_start_game()
signal on_new_patient()
signal on_end_game()
signal on_add_score(score: int)

signal hand_force_release_object()

var high_score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#on_start_game.emit()
