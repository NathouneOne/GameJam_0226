extends Node2D
class_name Defibrillator

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	useable.use_start.connect(_on_use_start)
	useable.use_stop.connect(_on_use_stop)

func _on_use_start(_owner: Node2D, target: Node2D, _hand: Node2D) -> void:
	
	if target is Heart:
		# todo: animate shock
		#flash_feedback.flash()
		$Iron_FX.show()
		$Iron_FX.play("Lightning")
		$AudioStreamPlayer2D.play()
		Global.camShake.emit()
	else:
	#	todo: feedback not ok
		#flash_feedback.flash()
		$Iron_FX.show()
		$Iron_FX.play("Smoke")
		$Vapeur.play()

func _on_use_stop(_owner: Node2D, _target: Node2D, _hand: Node2D) -> void:
	pass


func _on_iron_fx_animation_finished() -> void:
	$Iron_FX.hide()
