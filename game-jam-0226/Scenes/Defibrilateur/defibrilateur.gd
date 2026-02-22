extends Node2D
class_name Defibrillator

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	useable.use_started.connect(_on_use_started)
	useable.use_stop.connect(_on_use_stop)

func _on_use_started(_owner: Node2D, targets: Array[Node2D], _hand: Node2D) -> void:
	var has_heart := _targets_include_heart(targets)
	if has_heart:
		$Iron_FX.show()
		$Iron_FX.play("Lightning")
		$AudioStreamPlayer2D.play()
		Global.camShake.emit()
	else:
		$Iron_FX.show()
		$Iron_FX.play("Smoke")
		$Vapeur.play()

func _targets_include_heart(targets: Array[Node2D]) -> bool:
	for t: Node2D in targets:
		if t is Heart:
			return true
	return false

func _on_use_stop(_owner: Node2D, _target: Node2D, _hand: Node2D) -> void:
	pass


func _on_iron_fx_animation_finished() -> void:
	$Iron_FX.hide()
