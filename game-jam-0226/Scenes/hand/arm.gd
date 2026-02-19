@tool
extends Node2D

@export var target_node: Node2D
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
	toggle_sprite()
	pass
	

# follow target each frame
func _process(delta: float) -> void:
	if target_node:
		target.global_position = target_node.global_position
