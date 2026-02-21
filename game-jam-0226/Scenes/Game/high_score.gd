@tool
extends Node2D
class_name HighScore

var high_score := 0

@onready var scoreLabel: Label = $text/Score
@onready var jucyAudio: AudioStreamPlayer2D = $JuicyAudio
@onready var jucyParticles: GPUParticles2D = $JuicyParticles
@onready var feedback: FlashFeedback = $Feedback


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_new_high_score() -> void:
	jucyAudio.play()
	feedback.flash()
	get_tree().create_timer(0.5).timeout.connect(func() -> void: jucyParticles.emitting = true)
	

# Getter ensures the Callable is resolved when the button is used (avoids Nil at editor load).
@export_tool_button("hsa", "Callable") var hsa: Callable:
	get: return on_new_high_score
