extends Node2D



const CUT_Y_SIZE = 2
const SCALPEL_CUT = preload("uid://yj50mdywxph6")

var clic1 : Vector2
var clic2 : Vector2

var current_cut : StaticBody2D= SCALPEL_CUT.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	
	# Create and update cut 
	if is_instance_valid(current_cut) :
		if Input.is_action_just_pressed("left_clic"):
			clic1 = get_global_mouse_position()
			clic2 = get_global_mouse_position()
			current_cut = create_cut(clic1, clic2)
			
		if Input.is_action_pressed("left_clic"):
			clic2 = get_global_mouse_position()
			update_cut(clic1, clic2, current_cut)
		
		if Input.is_action_just_released("left_clic"):

				clic2 = get_global_mouse_position()
				
				
				current_cut.set_collision_layer(1)
				current_cut.set_collision_mask(1)
				
				update_cut(clic1, clic2, current_cut)






func create_cut(cut_coordinate_1 : Vector2, cut_coordinate_2 : Vector2) -> Node:
	
	
	#select box type
	var cut :StaticBody2D=SCALPEL_CUT.instantiate()
	
	
	cut.set_collision_layer(0)
	cut.set_collision_mask(0)
	
	update_cut(cut_coordinate_1, cut_coordinate_2, cut)
	
	cut.add_to_group("boxes")
	
	add_child(cut)
	
	
	return cut


func update_cut(cut_coordinate_1 : Vector2, cut_coordinate_2 : Vector2, cut : StaticBody2D) -> void:
	#if cut == StaticBody2D :
	#	pass
	
	var cut_size := Vector2(cut_coordinate_1.distance_to(cut_coordinate_2), CUT_Y_SIZE)
	var cut_angle := cut_coordinate_1.angle_to_point(cut_coordinate_2)
	
	#position box, collision_shape & skin
	cut.global_position.x=cut_coordinate_1.x
	cut.global_position.y=cut_coordinate_1.y
	
	cut.get_child(1).position=Vector2(0,0)
	cut.get_child(1).size=cut_size
	cut.get_child(0).shape.size=cut_size
	cut.get_child(0).position.x=cut_size.x/2
	cut.get_child(0).position.y=cut_size.y/2
	
	
	if cut == StaticBody2D :
		cut.get_child(2).get_child(0).shape.size = cut_size
		cut.get_child(2).get_child(0).position.x=cut_size.x/2
		cut.get_child(2).get_child(0).position.y=cut_size.y/2
	
	cut.global_rotation = cut_angle
