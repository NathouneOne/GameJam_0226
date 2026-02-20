extends Node2D
class_name Heart

@onready var interactive: Interactive = $Interactive
@onready var flash_feedback_ok: FlashFeedback = $FlashFeedbackOk
@onready var flash_feedback_nok: FlashFeedback = $FlashFeedbackNok
@onready var qteCoeur: Node2D = $QTECoeur


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
	return qteCoeur.scale.x > ZONE_OK.x and qteCoeur.scale.x < ZONE_OK.y
	

@export var SUCCESS_POINTS := 5
@export var DEFEAT_POINTS := -5

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	if disabled:
		return

	if source is Defibrillator and qte_ok():
		Global.on_add_score.emit(SUCCESS_POINTS)
		flash_feedback_ok.flash()
		qte_completed += 1
		if qte_completed >= 3:
			# disable the QTE:
			# TODO: animate ?
			disable()
			minigame_done.emit()
	else:
		Global.on_add_score.emit(DEFEAT_POINTS)
		flash_feedback_nok.flash()

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
	qteCoeur.visible = false


func reset(
	scale_trans: Tween.TransitionType = Tween.TRANS_SINE,
	scale_ease: Tween.EaseType = Tween.EASE_IN_OUT
) -> void:
	qte_completed = 0
	disabled = false
	qteCoeur.visible = true
	qteCoeur.scale = Vector2.ONE * SCALE_START
	
	# kill existing animation if any
	if heart_tween:
		heart_tween.kill()

	heart_tween = get_tree().create_tween().set_loops()
	heart_tween.tween_property(qteCoeur, "scale", Vector2.ONE * SCALE_END, SCALE_DURATION).set_trans(scale_trans).set_ease(scale_ease)
	heart_tween.tween_property(qteCoeur, "scale", Vector2.ONE * SCALE_START, SCALE_DURATION).set_trans(scale_trans).set_ease(scale_ease)

func _process(_delta: float) -> void:
	# is in suceess zone 
	if qte_ok():
		qteCoeur.modulate = ZONE_OK_MODULATE
		#print("ok")
	else:
		qteCoeur.modulate = ZONE_NOK_MODULATE
		#print("not ok")
