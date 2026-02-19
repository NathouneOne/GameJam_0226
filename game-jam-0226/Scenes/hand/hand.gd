extends Node2D

var closed: bool
@export var follow_speed: float = 15.0

var grabbed_object: Node2D = null
var grabbable_component: Grabbable = null

@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	closed = false;


func _process(delta: float) -> void:
	var target_pos: Vector2 = get_global_mouse_position()
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	_process_grabbed_object()
	
	if Input.is_action_just_pressed("left_clic"):
		if grabbed_object:
			_release_object()
		else:
			_try_grab_object()

func _try_grab_object() -> void:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	for area: Area2D in areas:
		if area is Grabbable:
			var target: Node = area.get_parent()
			if target is Node2D:
				_grab_object(target as Node2D, area as Grabbable)
				return

func _grab_object(object: Node2D, component: Grabbable) -> void:
	grabbed_object = object
	grabbable_component = component
	grabbable_component.grab(self)

func _release_object() -> void:
	if grabbable_component:
		grabbable_component.release()
	
	grabbed_object = null
	grabbable_component = null

func _process_grabbed_object() -> void:
	if grabbed_object:
		# move object 
		grabbed_object.global_position = global_position
