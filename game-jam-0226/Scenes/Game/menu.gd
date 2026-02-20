@tool
extends Node2D
class_name Menu


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rideauL: Sprite2D = $rideauL
@onready var rideauR: Sprite2D = $rideauR



func open() -> void:
	animation_player.play("open")

	

@export_tool_button("open", "Callable") var open_action: Callable:
	get: return open

func close() -> void:
	animation_player.play("close")
	

@export_tool_button("close", "Callable") var close_action: Callable:
	get: return close

func _ready() -> void:
	rideauL.position = Vector2(0.0,0.0)
	rideauR.position = Vector2(960.0,0.0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
