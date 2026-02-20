extends Node2D

class_name Plaie
var cut_started :bool =0

signal minigame_done()


const CHECK_POINT = preload("uid://oeb2gp4owcen")
const TELEPHONE = preload("uid://urhinpicu3w4")

@export var started: bool = true


var start_checkpoint := CHECK_POINT.instantiate()
var win:bool=0
var is_scalpel_inzone :bool=0
var already_won: bool =0
var handclic:bool =0
var telephone_grabbed :bool =0
var scalpel : Node2D
var telephone := TELEPHONE.instantiate()

@onready var interactive: Interactive = $Interactive



func _ready() -> void:
	Global.on_new_patient.connect(reset_minigame)
	
	interactive.interact_start.connect(_on_interact_start)
	interactive.interact_stop.connect(_on_interact_stop)
	
	
	if started:
		start()
	
	reset_minigame()

@export var SUCCESS_POINTS := 15
@export var DEFEAT_POINTS := -5

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	if source is Scalpel:
		scalpel=source.get_child(1)
		cut_started=1
	elif source != null:
		Global.on_add_score.emit(DEFEAT_POINTS)
	
	if source==null :
		handclic=1

func _on_interact_stop(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	cut_started=0
	handclic=0

func start() -> void:
	started = true

func stop() -> void:
	started = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## CUTTER ##
	if cut_started:
		for i in %Outline.get_overlapping_areas() :
			if i == scalpel :
				is_scalpel_inzone=1
				break
			else:
				is_scalpel_inzone=0
				
		for j in %Inline.get_overlapping_areas():
			if j == scalpel :
				is_scalpel_inzone=0
				break
					
		if Input.is_action_just_pressed("left_clic") :
			%ScalpelCurve.curve.clear_points()
			add_child(start_checkpoint)
			start_checkpoint.global_position = scalpel.global_position
			start_checkpoint.is_start_checkpoint = 1
			
			if not is_scalpel_inzone :
				Global.on_add_score.emit(DEFEAT_POINTS)
			
		if Input.is_action_pressed("left_clic"):
			%ScalpelCurve.curve.add_point(scalpel.global_position-global_position, Vector2(0,0), Vector2(0,0))
			for i in get_children() :
				win=1
				if i.is_in_group("checkpoint") :
					if not i.is_triggered :
						win=0
						break
			if win :
				if not start_checkpoint.is_start_checkpoint and not already_won:
					Global.on_add_score.emit(SUCCESS_POINTS)
					already_won =1
					print("You win")
				else :
					start_checkpoint.is_start_checkpoint=0
					start_checkpoint.is_triggered = 0
			
		if Input.is_action_just_released("left_clic"):
			start_checkpoint.queue_free()
			for i in get_children() :
				if i.is_in_group("checkpoint") :
					i.is_triggered=0	
	
	queue_redraw()
	
	## RETIRER SKIN ##
	# en signal
	
	## pick telephone ##
	


func _draw():
	if %ScalpelCurve.curve.point_count>2 :
		draw_polyline(%ScalpelCurve.curve.get_baked_points(), Color(124.999, 0.0, 0.0, 1.0), 4, true)

func _on_inline_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == scalpel :
		if Input.is_action_pressed("left_clic") and cut_started :
				Global.on_add_score.emit(DEFEAT_POINTS)


func _on_outline_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
		if area == scalpel :
			var local_inzone:bool = 0
			for i in %Outline.get_overlapping_areas() :
				if i == scalpel :
					local_inzone=1
					break
			if Input.is_action_pressed("left_clic") and cut_started and not local_inzone:
				Global.on_add_score.emit(DEFEAT_POINTS)


func _on_outline_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("left_clic") and already_won and handclic and not telephone_grabbed:
		%PlaiePng.hide()
		%PlaieOuvertePng2.show()
		%ScalpelCurve.curve.clear_points()
		queue_redraw()
		get_parent().get_parent().add_child(telephone)
		telephone.global_position = %PlaieOuvertePng2.global_position
		telephone.scale = %PlaieOuvertePng2.scale-Vector2(0.1,0.1)
		handclic=0
		telephone_grabbed =1


func tel_poubelle():
		minigame_done.emit()

func reset_minigame():
	%ScalpelCurve.curve.clear_points()
	%PlaiePng.show()
	%PlaieOuvertePng2.hide()
	#telephone.queue_free()
	telephone = TELEPHONE.instantiate()
	telephone.connect("telephone_poubelle", tel_poubelle)
	start_checkpoint = CHECK_POINT.instantiate()
	win=0
	is_scalpel_inzone =0
	already_won=0
	handclic=0
	telephone_grabbed =0
	
