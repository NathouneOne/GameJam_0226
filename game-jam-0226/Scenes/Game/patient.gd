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
		if coeur1:
			coeur1.visible = v
@export var COEUR_2_ENABLED := true:
	set(v):
		COEUR_2_ENABLED = v
		if coeur2:
			coeur2.visible = v

# Add other minigames here


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coeur1.visible = COEUR_1_ENABLED
	coeur2.visible = COEUR_2_ENABLED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
