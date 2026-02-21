extends Node2D

const GAME = preload("res://Scenes/Game/game.tscn")

@export var transition_delay_in: float = 1.0
@export var transition_delay_out: float = 2

@onready var game: Game = $Game
@onready var menu: Menu = $Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# delete the editor game, it will be re instantiated
	_cleanup_game()
	menu.open_trigger.connect(_start_game)
	Global.on_end_game.connect(_end_game)

	pass # Replace with function body.

func _start_game() -> void:
	game = GAME.instantiate()
	add_child(game)
	# Wait 1 sec and emit the signal
	get_tree().create_timer(transition_delay_in).timeout.connect(func(): Global.on_start_game.emit())

func _end_game() -> void: 
	menu.close()
	get_tree().create_timer(transition_delay_out).timeout.connect(_cleanup_game)
	

func _cleanup_game() -> void:
	game.queue_free()
	game = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
