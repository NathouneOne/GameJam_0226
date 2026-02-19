extends Area2D
var is_triggered: bool =0
var is_start_checkpoint: bool =0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_mouse_entered() -> void:
	if Input.is_action_pressed("left_clic") :
		print("checkpoint_trigered")
		is_triggered=1
