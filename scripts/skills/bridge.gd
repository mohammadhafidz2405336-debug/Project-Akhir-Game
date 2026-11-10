extends StaticBody2D
## Bridge - jembatan Relation Bridge hasil link FK->PK yang valid (GDD 3.3).

@export var lifetime := 20.0

var _from := Vector2.ZERO
var _to := Vector2.ZERO

@onready var timer: Timer = $Timer
@onready var line: Line2D = $Line2D
@onready var shape_node: CollisionShape2D = $CollisionShape2D

func setup(from: Vector2, to: Vector2) -> void:
	_from = from
	_to = to

func _ready() -> void:
	add_to_group("bridge")
	if _to == Vector2.ZERO:
		_to = _from + Vector2(96, 0)
	var mid := (_from + _to) * 0.5
	var length := _from.distance_to(_to)
	global_position = mid
	var angle := (_to - _from).angle()
	rotation = angle
	var rect := RectangleShape2D.new()
	rect.size = Vector2(maxf(16.0, length), 10.0)
	shape_node.shape = rect
	line.points = PackedVector2Array([Vector2(-length * 0.5, 0), Vector2(length * 0.5, 0)])
	line.width = 4.0
	timer.wait_time = lifetime
	timer.timeout.connect(dissolve)
	timer.start()
	modulate = Color(1, 1, 1, 0)
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.18)

func dissolve() -> void:
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "modulate", Color(1, 0.4, 1, 0), 0.35)
	t.tween_property(line, "width", 0.0, 0.35)
	await t.finished
	queue_free()
