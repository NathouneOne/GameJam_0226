extends Node2D
class_name Scalpel

@onready var useable: Useable = $Useable

#@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	useable.use_start.connect(_on_use_start)
	useable.use_stop.connect(_on_use_stop)
	%GPUParticles2D.emitting=0

func _on_use_start(_owner: Node2D, target: Node2D, _hand: Node2D) -> void:
	%GPUParticles2D.emitting=1
	

func _on_use_stop(_owner: Node2D, _target: Node2D, _hand: Node2D) -> void:
	%GPUParticles2D.emitting=0
