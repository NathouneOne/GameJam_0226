@tool
extends Node2D

@export var target_node: Node2D
@onready var target: Node2D = $target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# follow target each frame
func _process(delta: float) -> void:
	target.global_position = target_node.global_position
