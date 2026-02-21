extends Node2D
class_name GameScore

signal on_timer_end()

@onready var label := $ScoreLabel as Label
var score := 0

const BANANASPAWNER = preload("res://Scenes/Components/BananaParticlesSpawner.tscn")
var BananaSpawner :Node


func init_() -> void:
	score = 0

func add(points: int) -> void:
	var old_score := score
	score += points
	
	if points < 0:
		_animate_negative_points(old_score)
	else:
		_animate_postive_points(old_score)
	

	
func _animate_postive_points(_old_score: int) -> void:
	# TODO better animation
	$FlashFeedbackOk.flash()
	
	BananaSpawner = BANANASPAWNER.instantiate()
	add_child(BananaSpawner)
	BananaSpawner.play()
	
	update_label()


func _animate_negative_points(_old_score: int) -> void:
	# TODO better animation
	$FlashFeedbackNotOk.flash()
	%HurtingSound.play()
	Global.camShake.emit()
	update_label()


func on_done() -> void:
	on_timer_end.emit()

func update_label() -> void:
	label.text = "%d" % score


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.on_start_game.connect(init_)
	Global.on_add_score.connect(add)
	update_label()


func _on_banana_particles_finished() -> void:
	%BananaParticles.emitting=false
