extends Node2D

signal telephone_poubelle()

const SUCCESS_POINTS:=35
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$Poubellable.connect("released", end_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func end_game()->void :
	telephone_poubelle.emit()
	Global.on_add_score.emit(SUCCESS_POINTS)
