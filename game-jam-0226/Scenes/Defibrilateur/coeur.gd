extends Node2D
class_name Heart

@onready var interactive: Interactive = $Interactive

@export var max_qte := 2

var beat: bool = 1


# TODO: call when minigame is complete
signal minigame_done()

# Coeur is complete when 3 QTE done 
var qte_completed := 0

func _ready() -> void:
	interactive.interact_start.connect(_on_interact_start)
	interactive.interact_stop.connect(_on_interact_stop)
	Global.on_new_patient.connect(reset)
	reset()
	

func qte_ok() -> bool:
	#return qteCoeur.scale.x > ZONE_OK.x and qteCoeur.scale.x < ZONE_OK.y
	var frame: int = $AnimatedSprite2D.frame
	var in_zone: bool = frame >= 10 and frame <= 16
	push_warning("[Coeur] qte_ok() frame=%d (zone 10-16) => %s" % [frame, in_zone])
	if in_zone:
		return true
	else:
		return false

@export var SUCCESS_POINTS := 50
@export var DEFEAT_POINTS := -50

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D, _targets_for_use: Array[Node2D] = []) -> void:
	var source_name: String = source.name if source else "null"
	var source_class: String = source.get_class() if source else "?"
	print("[Coeur] _on_interact_start target=%s source=%s (class=%s) disabled=%s" % [_target.name if _target else "null", source_name, source_class, disabled])
	if disabled:
		print("[Coeur] ignored (disabled)")
		return

	if source is Defibrillator:
		var ok: bool = qte_ok()
		print("[Coeur] Defibrillator hit: qte_ok=%s (frame=%d), qte_completed=%d/%d -> %s" % [ok, $AnimatedSprite2D.frame, qte_completed, max_qte, "SUCCESS +pts" if ok else "MISS -pts"])
		if ok:
			print("[Coeur] SUCCESS -> +%d pts" % SUCCESS_POINTS)
			Global.on_add_score.emit(SUCCESS_POINTS)
			qte_completed += 1
			scale.x *= -1
			if qte_completed >= max_qte:
				# disable the QTE:
				# TODO: animate ?
				$HeartBeat.stop()
				beat = 0
				$AnimatedSprite2D.hide()
				disable()
				minigame_done.emit()
		else:
			print("[Coeur] MISS (hit patient) -> %d pts" % DEFEAT_POINTS)
			Global.on_add_score.emit(DEFEAT_POINTS)
	else:
		print("[Coeur] ignored (source is not Defibrillator)")

func _on_interact_stop(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	pass


var heart_tween: Tween

@export var SCALE_START := 1.5
@export var SCALE_END := 0.6
@export var SCALE_DURATION := 1.0
@export var ZONE_OK := Vector2(0.9, 1.2)
@export var ZONE_OK_MODULATE: Color
@export var ZONE_NOK_MODULATE: Color

var disabled := false
func disable() -> void:
	disabled = true


func reset(
	scale_trans: Tween.TransitionType = Tween.TRANS_SINE,
	scale_ease: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("HeartBeat1")
	$HeartBeat.show()
	beat = 1
	
	qte_completed = 0
	disabled = false

func _process(_delta: float) -> void:
	if $AnimatedSprite2D.frame == 8 and beat:
		$Timer.start()
		$HeartBeat.play()


func _on_timer_timeout() -> void:
	$HeartBeat.stop()
