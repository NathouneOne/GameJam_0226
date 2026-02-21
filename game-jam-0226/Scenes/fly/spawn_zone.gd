extends Area2D
class_name SpawnZone

var _spawn_shapes: Array[Dictionary] = [] # { "global_position": Vector2, "radius": float }


func _ready() -> void:
	_build_spawn_shapes()


func _build_spawn_shapes() -> void:
	_spawn_shapes.clear()
	for child in get_children():
		var shape_node: CollisionShape2D = child as CollisionShape2D
		if shape_node and shape_node.shape is CircleShape2D:
			var circle: CircleShape2D = shape_node.shape as CircleShape2D
			var global_center: Vector2 = shape_node.global_position
			var scale_factor: float = (shape_node.global_scale.x + shape_node.global_scale.y) * 0.5
			var radius: float = circle.radius * scale_factor
			_spawn_shapes.append({"global_position": global_center, "radius": radius})
	if _spawn_shapes.is_empty():
		_spawn_shapes.append({"global_position": global_position, "radius": 50.0})
		print("[SpawnZone] no CircleShape2D children, using fallback at ", global_position)
	else:
		print("[SpawnZone] built ", _spawn_shapes.size(), " spawn shape(s)")


## Returns a random global position inside one of this zone's shapes (supports CircleShape2D).
func get_random_spawn_position() -> Vector2:
	if _spawn_shapes.is_empty():
		return global_position
	var s: Dictionary = _spawn_shapes.pick_random()
	var center: Vector2 = s.global_position
	var radius: float = s.radius
	return center + Vector2.from_angle(randf() * TAU) * randf() * radius
