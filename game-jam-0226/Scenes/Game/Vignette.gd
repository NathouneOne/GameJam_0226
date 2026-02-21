extends CanvasLayer

@onready var ellapsedtime = 60-%GameTime.remaining_time_seconds
var opacityValue :float =0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ellapsedtime = 60-%GameTime.remaining_time_seconds
	opacityValue = ellapsedtime/60
	%VignetteRouge.modulate.a=opacityValue
	
