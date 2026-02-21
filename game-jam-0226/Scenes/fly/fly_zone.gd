extends Area2D
class_name FlyZone

var _shape: CollisionShape2D
var _capsule: CapsuleShape2D
var _shape_transform: Transform2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_shape = get_node_or_null("CollisionShape2D")
	if _shape and _shape.shape is CapsuleShape2D:
		_capsule = _shape.shape as CapsuleShape2D
	_update_shape_transform()


func _process(_delta: float) -> void:
	_update_shape_transform()


func _update_shape_transform() -> void:
	if _shape:
		_shape_transform = _shape.global_transform


## Returns true if global_pos is inside this zone's shape.
func is_point_inside(global_pos: Vector2) -> bool:
	if not _capsule:
		return false
	var local := _shape_transform.affine_inverse() * global_pos
	return _point_in_capsule_local(local)


## Returns global_pos clamped to the nearest point inside the zone.
func clamp_position(global_pos: Vector2) -> Vector2:
	if not _capsule:
		return global_pos
	var local := _shape_transform.affine_inverse() * global_pos
	var clamped_local := _clamp_to_capsule_local(local)
	return _shape_transform * clamped_local


func _point_in_capsule_local(p: Vector2) -> bool:
	var r := _capsule.radius
	var h := _capsule.height
	# Capsule segment (circle centers): from (0, -h/2 + r) to (0, h/2 - r)
	var half := h / 2.0 - r
	var a := Vector2(0, -half)
	var b := Vector2(0, half)
	var ab := b - a
	var ap := p - a
	var t := clampf(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
	var closest := a + t * ab
	return p.distance_to(closest) <= r


func _clamp_to_capsule_local(p: Vector2) -> Vector2:
	var r := _capsule.radius
	var h := _capsule.height
	var half := h / 2.0 - r
	var a := Vector2(0, -half)
	var b := Vector2(0, half)
	var ab := b - a
	var ap := p - a
	var t := clampf(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
	var closest := a + t * ab
	var dist := p.distance_to(closest)
	if dist <= r:
		return p
	var dir := (p - closest).normalized()
	return closest + dir * r
