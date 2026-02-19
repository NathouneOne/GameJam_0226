extends Node2D
class_name Hand

@export var follow_speed: float = 15.0

var grabbed_object: Node2D = null
var grabbable_component: Grabbable = null
var useable_component: Useable = null

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	%LeftArm.closed = false;
	return


func _process(delta: float) -> void:
	var target_pos: Vector2 = get_global_mouse_position()
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	_process_grabbed_object()
	
	if Input.is_action_just_pressed("left_clic"):
		if grabbed_object:
			if not _release_object():
				_use_held_object()
		else:
			if not _try_grab_object():
				_try_interact_empty_hand()

func _try_grab_object() -> bool:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	for area: Area2D in areas:
		if area is Grabbable:
			var target: Node = area.get_parent()
			if target is Node2D:
				_grab_object(target as Node2D, area as Grabbable)
				return true
	return false

func _grab_object(object: Node2D, component: Grabbable) -> void:
	grabbed_object = object
	grabbable_component = component
	%LeftArm.closed = true;
	grabbable_component.grab(self)
	useable_component = _find_component_in_object(object, Useable) as Useable

func _release_object() -> bool:
	if grabbable_component:
		if grabbable_component.release():
			grabbed_object = null
			grabbable_component = null
			useable_component = null
			%LeftArm.closed = false;
			return true
	return false

func _process_grabbed_object() -> void:
	if grabbed_object:
		# move object 
		grabbed_object.global_position = global_position

func _use_held_object() -> bool:
	if useable_component == null:
		return false
	return useable_component.use(self)

func _try_interact_empty_hand() -> bool:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	for area: Area2D in areas:
		if area is Interactive:
			return (area as Interactive).interact(null, self)
	return false

func _find_component_in_object(object: Node, component_type: Variant) -> Node:
	for child: Node in object.get_children():
		if is_instance_of(child, component_type):
			return child
	return null
