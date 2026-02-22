extends Node2D

class_name Plaie
var cut_started: bool = 0

signal minigame_done()


const CHECK_POINT = preload("res://Scenes/Scalpel/CheckPoint.tscn")
const TELEPHONE = preload("res://Scenes/Scalpel/Telephone.tscn")

@export var started: bool = true


var win: bool = 0
var is_scalpel_inzone: bool = 0
var handclic: bool = 0
var telephone_grabbed: bool = 0
var scalpel: Node2D
var telephone := TELEPHONE.instantiate()
var telephone_original_pos: Vector2
var jitter: bool = 0
var original_pos :Vector2 
var stop_jitter: bool = 0


@onready var interactive: Interactive = $Interactive


func _ready() -> void:
	Global.on_new_patient.connect(reset_minigame)
	
	interactive.interact_start.connect(_on_interact_start)
	interactive.interact_stop.connect(_on_interact_stop)
	
	original_pos= position
	
	if started:
		start()
	
	reset_minigame()

@export var SUCCESS_POINTS := 150
@export var DEFEAT_POINTS := -50

func _on_interact_start(_target: Node2D, source: Node2D, _hand: Node2D) -> void:
	if source is Scalpel:
		scalpel = source.get_child(1)
		cut_started = 1
	elif source != null:
		Global.on_add_score.emit(DEFEAT_POINTS)
	
	if source == null:
		handclic = 1

func _on_interact_stop(_target: Node2D, _source: Node2D, _hand: Node2D) -> void:
	
	for i in get_children():
		if i.is_in_group("checkpoint"):
			i.is_triggered = 0
	
	
	cut_started = 0
	handclic = 0

func start() -> void:
	started = true

func stop() -> void:
	started = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	## CUTTER ##
	if cut_started:
		#check if scalpel is cutting inzone (in outline, but outside inline)
		for i in %Outline.get_overlapping_areas():
			if i == scalpel:
				is_scalpel_inzone = 1
				for j in %Inline.get_overlapping_areas():
					if j == scalpel:
						is_scalpel_inzone = 0
						break
				break
			else:
				is_scalpel_inzone = 0
		
		#Reset curve, if not inzone defeat
		if Input.is_action_just_pressed("left_clic"):
			%ScalpelCurve.curve.clear_points()
			
			if not is_scalpel_inzone:
				Global.on_add_score.emit(DEFEAT_POINTS)
			
		if Input.is_action_pressed("left_clic"):
			%ScalpelCurve.curve.add_point(scalpel.global_position - global_position, Vector2(0, 0), Vector2(0, 0))
			#Victory condition
			for i in get_children():
				win = 1
				if i.is_in_group("checkpoint"):
					if not i.is_triggered:
						win = 0
						break
			if win:
					Global.on_add_score.emit(SUCCESS_POINTS)
					## THIS PART WAS "_on_outline_input_event()"
					%PlaiePng.hide()
					%PlaieOuvertePng2.show()
					%ScalpelCurve.curve.clear_points()
					get_parent().get_parent().add_child(telephone)
					telephone.global_position = %PlaieOuvertePng2.global_position
					telephone_original_pos = telephone.global_position
					telephone.scale = %PlaieOuvertePng2.scale - Vector2(0.1, 0.1)
					handclic = 0
					telephone_grabbed = 1
					#reset checkpoints for no winspam
					for i in get_children():
						if i.is_in_group("checkpoint"):
							i.is_triggered=0
	
	queue_redraw()
	
	## Jitter
	if telephone.get_child(1).is_grabbed:
		stop_jitter = 1
		%TelephoneVibreur.stop()
		%TelephoneVibreurEtouffe.stop()
	
	if jitter and not telephone_grabbed:
		position = original_pos + Vector2((randf() - 0.5) * 5, (randf() - 0.5) * 5)
		%TelephoneVibreurEtouffe.play()
	elif not jitter and not telephone_grabbed:
		%TelephoneVibreurEtouffe.stop()
		%TelephoneVibreur.stop()
		position = original_pos
	elif jitter and telephone_grabbed and not stop_jitter:
		%TelephoneVibreur.play()
		telephone.global_position = telephone_original_pos + Vector2((randf() - 0.5) * 5, (randf() - 0.5) * 5)
	elif not jitter and telephone_grabbed and not stop_jitter:
		%TelephoneVibreur.stop()
		%TelephoneVibreurEtouffe.stop()
		telephone.global_position = telephone_original_pos

func _draw():
	if %ScalpelCurve.curve.point_count > 2:
		draw_polyline(%ScalpelCurve.curve.get_baked_points(), Color(124.999, 0.0, 0.0, 1.0), 4, true)

func _on_inline_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area == scalpel:
		if Input.is_action_pressed("left_clic") and cut_started:
				Global.on_add_score.emit(DEFEAT_POINTS)


func _on_outline_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
		if area == scalpel:
			var local_inzone: bool = 0
			for i in %Outline.get_overlapping_areas():
				if i == scalpel:
					local_inzone = 1
					break
			if Input.is_action_pressed("left_clic") and cut_started and not local_inzone:
				Global.on_add_score.emit(DEFEAT_POINTS)



func tel_poubelle():
		minigame_done.emit()
		#Audio
		%TelephonePoubelle.play()

func reset_minigame():
	%TelephoneVibreur.stop()
	%TelephoneVibreurEtouffe.stop()
	%ScalpelCurve.curve.clear_points()
	%PlaiePng.show()
	%PlaieOuvertePng2.hide()
	telephone = TELEPHONE.instantiate()
	telephone.connect("telephone_poubelle", tel_poubelle)
	win = 0
	is_scalpel_inzone = 0
	handclic = 0
	telephone_grabbed = 0
	stop_jitter = 0
	

func _on_timer_timeout() -> void:
	%Timer2.start()
	jitter = 1


func _on_timer_2_timeout() -> void:
	jitter = 0
