@tool
extends Node2D
class_name Patient

# TODO: Emit when minigame is done
signal minigame_done()

@onready var coeur1: Heart = $Coeur1
@onready var coeur2: Heart = $Coeur2

@export var COEUR_1_ENABLED := true:
	set(v):
		COEUR_1_ENABLED = v
		if COEUR_1_ENABLED:
			coeur1.visible = true
		else:
			coeur2.visible = false

@export var COEUR_2_ENABLED := true:
	set(v):
		COEUR_2_ENABLED = v
		if COEUR_2_ENABLED:
			coeur1.visible = true
		else:
			coeur2.visible = false

# Add other minigames here


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
