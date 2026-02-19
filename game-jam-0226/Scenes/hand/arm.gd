@tool
extends Node2D
class_name Arm

const TARGET_MAX_RADIUS: float = 1000.0

@onready var target: Node2D = $target
@export var closed: bool = false:
	get:
		return closed
	set(v):
		closed = v
		toggle_sprite()

func toggle_sprite():
	if closed:
		$hand/closed.visible = true
		$hand/open.visible = false
	else:
		$hand/closed.visible = false
		$hand/open.visible = true
		
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ms: SkeletonModificationStack2D = $Skeleton2D.get_modification_stack()
	ms.enabled = true
	toggle_sprite()
	pass
	

# Mouse is the IK target; clamp to radius to avoid IK bugs
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var origin: Vector2 = global_position
	var diff: Vector2 = mouse_pos - origin
	if diff.length() > TARGET_MAX_RADIUS:
		#diff = diff.normalized() * TARGET_MAX_RADIUS
		pass
	target.global_position = origin + diff
