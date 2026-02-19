# This is a signal bus made for easy sharing of values / actions
extends Node
class_name Globals

signal on_start_game()
signal on_end_game()
signal on_add_score(int)

func add_score(score: int) -> void:
	on_add_score.emit(score)
