extends Node2D
const CHECK_POINT = preload("uid://oeb2gp4owcen")

var start_checkpoint := CHECK_POINT.instantiate()
var win:bool=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_clic") :
		%ScalpelCurve.curve.clear_points()
		start_checkpoint.global_position = get_global_mouse_position()
		add_child(start_checkpoint)
		start_checkpoint.is_start_checkpoint = 1
		
	
	if Input.is_action_pressed("left_clic"):
		%ScalpelCurve.curve.add_point(get_global_mouse_position(), Vector2(0,0), Vector2(0,0))
		for i in get_children() :
			win=1
			if i.is_in_group("checkpoint") :
				if not i.is_triggered :
					win=0
					break
		if win :
			if not start_checkpoint.is_start_checkpoint :
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
	


func _draw():
	if %ScalpelCurve.curve.point_count>2 :
		draw_polyline(%ScalpelCurve.curve.get_baked_points(), Color(124.999, 0.0, 0.0, 1.0), 1, true)


func _on_target_mouse_shape_entered(shape_idx: int) -> void:
	if (shape_idx==2 or shape_idx==3) and Input.is_action_pressed("left_clic"):
		print ("game over")
		
	


func _on_target_mouse_exited() -> void:
	if Input.is_action_pressed("left_clic"):
		print ("game over")
