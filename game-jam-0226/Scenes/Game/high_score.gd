@tool
extends Node2D
class_name HighScore

var high_score := 0

@onready var scoreLabel: Label = $text/Score
@onready var juicyAudio: AudioStreamPlayer2D = $JuicyAudio
@onready var juicyParticles: GPUParticles2D = $JuicyParticles
@onready var feedback: FlashFeedback = $Feedback

func update_label() -> void:
	if scoreLabel:
		scoreLabel.text = "%d" % high_score


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.end_game_score.connect(on_new_score)
	update_label()
	pass # Replace with function body.

func on_new_score(score: int) -> void:
	print("ON NEW SCORE: %d" % score)
	if score > high_score:
		high_score = score
		update_label()
		get_tree().create_timer(0.5).timeout.connect(on_new_high_score)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_new_high_score() -> void:
	juicyAudio.play()
	feedback.flash()
	get_tree().create_timer(0.5).timeout.connect(func() -> void: juicyParticles.emitting = true)
	

# Getter ensures the Callable is resolved when the button is used (avoids Nil at editor load).
@export_tool_button("hsa", "Callable") var hsa: Callable:
	get: return on_new_high_score
