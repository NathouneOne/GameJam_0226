extends Node2D
class_name Defibrillator

## True if the current/last use hit at least one Heart (so e.g. Plaie should not take damage).
var last_use_hit_heart: bool = false

@onready var useable: Useable = $Useable
@onready var flash_feedback: FlashFeedback = $FlashFeedback

func _ready() -> void:
	useable.use_started.connect(_on_use_started)
	useable.use_stop.connect(_on_use_stop)

func _on_use_started(_owner: Node2D, targets: Array[Node2D], _hand: Node2D) -> void:
	var target_infos: Array[String] = []
	var has_heart := false
	for t: Node2D in targets:
		var is_heart: bool = t is Heart
		if is_heart:
			has_heart = true
		target_infos.append("%s(is_heart=%s)" % [t.name, is_heart])
	last_use_hit_heart = has_heart
	print("[Defibrillator] use_started targets=%d %s -> has_heart=%s -> %s" % [targets.size(), str(target_infos), has_heart, "Lightning" if has_heart else "Smoke"])
	if has_heart:
		$Iron_FX.show()
		$Iron_FX.play("Lightning")
		$AudioStreamPlayer2D.play()
		Global.camShake.emit()
	else:
		$Iron_FX.show()
		$Iron_FX.play("Smoke")
		$Vapeur.play()

func _on_use_stop(_owner: Node2D, _target: Node2D, _hand: Node2D) -> void:
	pass


func _on_iron_fx_animation_finished() -> void:
	$Iron_FX.hide()
