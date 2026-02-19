extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_clic") :
		%ScalpelCurve.curve.clear_points()
	
	if Input.is_action_pressed("left_clic"):
		%ScalpelCurve.curve.add_point(get_global_mouse_position(), Vector2(0,0), Vector2(0,0))
		
	
	
	queue_redraw()
	
func _draw():
	if %ScalpelCurve.curve.point_count>2 :
		draw_polyline(%ScalpelCurve.curve.get_baked_points(), Color(124.999, 0.0, 0.0, 1.0), 1, false)


func _on_target_mouse_shape_entered(shape_idx: int) -> void:
	if (shape_idx==2 or shape_idx==3) and Input.is_action_pressed("left_clic"):
		print ("game over")


func _on_target_mouse_exited() -> void:
	if Input.is_action_pressed("left_clic"):
		print ("game over")
