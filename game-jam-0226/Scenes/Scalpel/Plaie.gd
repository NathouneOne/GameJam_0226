extends Node2D

class_name Plaie
var cut_started :bool =0

@onready var interactive: Interactive = $Interactive
#@onready var flash_feedback_ok: FlashFeedback = $FlashFeedbackOk
#@onready var flash_feedback_nok: FlashFeedback = $FlashFeedbackNok
#@onready var qteCoeur: Node2D = $QTECoeur


const CHECK_POINT = preload("uid://oeb2gp4owcen")

var start_checkpoint := CHECK_POINT.instantiate()
var win:bool=0


@export var started: bool = true


func _ready() -> void:
	interactive.interact_start.connect(_on_interact_start)
	interactive.interact_stop.connect(_on_interact_stop)
	
	if started:
		start()

@export var SUCCESS_POINTS := 15
@export var DEFEAT_POINTS := -5

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	if source is Scalpel:
		cut_started=1
	elif source != null:
		Global.on_add_score.emit(DEFEAT_POINTS)

func _on_interact_stop(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	cut_started=0


func start() -> void:
	started = true
	

func stop() -> void:
	started = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if cut_started:
		if Input.is_action_just_pressed("left_clic") :
			%ScalpelCurve.curve.clear_points()
			add_child(start_checkpoint)
			start_checkpoint.global_position = %Scalpel/Useable.global_position
			start_checkpoint.is_start_checkpoint = 1
			


		if Input.is_action_pressed("left_clic"):
			%ScalpelCurve.curve.add_point(%Scalpel/Useable.global_position, Vector2(0,0), Vector2(0,0))
			for i in get_children() :
				win=1
				if i.is_in_group("checkpoint") :
					if not i.is_triggered :
						win=0
						break
			if win :
				if not start_checkpoint.is_start_checkpoint :
					Global.on_add_score.emit(SUCCESS_POINTS)
					print("You win")
				else :
					start_checkpoint.is_start_checkpoint=0
					start_checkpoint.is_triggered = 0
			if 
				
			
		if Input.is_action_just_released("left_clic"):
			start_checkpoint.queue_free()
			for i in get_children() :
				if i.is_in_group("checkpoint") :
					i.is_triggered=0
	
	queue_redraw()
	


func _draw():
	if %ScalpelCurve.curve.point_count>2 :
		draw_polyline(%ScalpelCurve.curve.get_baked_points(), Color(124.999, 0.0, 0.0, 1.0), 4, true)


func _on_interactive_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == %Scalpel/Useable :
		if (local_shape_index==3 or local_shape_index==4) and Input.is_action_pressed("left_clic") and cut_started:
			Global.on_add_score.emit(DEFEAT_POINTS)


func _on_interactive_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == %Scalpel/Useable :
		if local_shape_index>4 and Input.is_action_pressed("left_clic") and cut_started:
			Global.on_add_score.emit(DEFEAT_POINTS)
