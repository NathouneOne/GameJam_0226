extends Node2D
class_name Hand

var grabbed_object: Node2D = null
var grabbable_component: Grabbable = null
var poubellable_component: Poubellable = null
var useable_component: Useable = null
var grab_offset: Vector2 = Vector2.ZERO # object position in hand's local space when grabbed
var grab_rotation_offset: float = 0.0 # object rotation relative to hand when grabbed
var use_fixed_x: bool = false
var grab_fixed_x: float = 0.0 # used when use_fixed_x
var use_fixed_rotation: bool = false
var grab_fixed_rotation: float = 0.0 # used when use_fixed_rotation

@onready var area_2d: Area2D = $Area2D
@onready var arm: Arm = $"../.."

func _ready() -> void:
	arm.closed = false
	Global.hand_force_release_object.connect(_force_release_object)
	Global.on_end_game.connect(_force_release_object)


func _process(_delta: float) -> void:
	_process_grabbed_object()
	# When holding a position_y_only object, clip the arm target to the object's X (like radius clip)
	if use_fixed_x and arm.target:
		var t := arm.target.global_position
		t.x = grab_fixed_x
		arm.target.global_position = t

	if Input.is_action_just_pressed("left_clic"):
		if grabbed_object:
			if not _release_object():
				_use(true)
		else:
			if not _try_grab_object():
				_try_interact_empty_hand()
	if Input.is_action_just_released("left_clic"):
		_use(false)

func _try_grab_object() -> bool:
	var areas: Array[Area2D] = area_2d.get_overlapping_areas()
	for area: Area2D in areas:
		if area is Grabbable:
			var g: Grabbable = area as Grabbable
			if g.disabled:
				continue
			var target: Node = area.get_parent()
			if target is Node2D:
				_grab_object(target as Node2D, g)
				return true

		if area is Poubellable:
			var target: Node = area.get_parent()
			if target is Node2D:
				_grab_poubelle_object(target as Node2D, area as Poubellable)
				return true
	return false

func _grab_object(object: Node2D, component: Grabbable) -> void:
	grabbed_object = object
	grabbable_component = component
	# Store where the object was relative to the hand so it doesn't snap to hand center
	grab_offset = global_transform.affine_inverse() * object.global_position
	grab_rotation_offset = wrapf(object.global_rotation - global_rotation, -PI, PI)
	use_fixed_x = component.position_y_only
	if use_fixed_x:
		grab_fixed_x = object.global_position.x
	use_fixed_rotation = component.lock_rotation
	if use_fixed_rotation:
		grab_fixed_rotation = object.global_rotation
	arm.closed = true;
	grabbable_component.grab(self)
	useable_component = _find_component_in_object(object, Useable) as Useable
	
func _grab_poubelle_object(object: Node2D, component: Poubellable) -> void:
	grabbed_object = object
	poubellable_component = component
	# Store where the object was relative to the hand so it doesn't snap to hand center
	grab_offset = global_transform.affine_inverse() * object.global_position
	grab_rotation_offset = wrapf(object.global_rotation - global_rotation, -PI, PI)
	arm.closed = true;
	poubellable_component.grab(self)
	useable_component = _find_component_in_object(object, Useable) as Useable

func _release_object() -> bool:
	print("[Hand] _release_object")
	if grabbable_component:
		if grabbable_component.release():
			_force_release_object()
			return true
			
	if poubellable_component:
		if poubellable_component.release():
			_force_release_object()
			return true
	return false

func _force_release_object() -> void:
	_use(false)
	grabbed_object = null
	grabbable_component = null
	poubellable_component = null
	useable_component = null
	use_fixed_x = false
	use_fixed_rotation = false
	arm.closed = false


func _process_grabbed_object() -> void:
	if grabbed_object:
		var target_global := global_transform * grab_offset
		if use_fixed_x:
			grabbed_object.global_position = Vector2(grab_fixed_x, target_global.y)
		else:
			grabbed_object.global_position = target_global
		if use_fixed_rotation:
			grabbed_object.global_rotation = grab_fixed_rotation # keep initial object rotation
		else:
			grabbed_object.global_rotation = global_rotation + grab_rotation_offset # follow hand, no snap

func _use(is_start: bool) -> void:
	if useable_component == null:
		return
	if is_start:
		useable_component.use(self)
	else:
		useable_component.stop_use(self)

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
