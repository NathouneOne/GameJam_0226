extends Camera2D

var shake:bool=0
var original_position = position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camShake.connect(camshake)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake :
		position=original_position+Vector2((randf()-0.5)*5, (randf()-0.5)*5)
	else :
		position = original_position


func camshake() ->void:
	shake=1
	$Timer.start()


func _on_timer_timeout() -> void:
	shake=0
