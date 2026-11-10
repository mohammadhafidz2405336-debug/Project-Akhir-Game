extends Area2D
## UniqueStrike - terjangan 80 px; melukai musuh dan memicu PKBarrier (GDD 3.3).

const TRAVEL := 80.0
const SPEED := 320.0

var dir := 1
var damage := 4
var _traveled := 0.0
var _hit_ids := {}

@onready var sprite: Sprite2D = $Sprite2D

func setup(direction: int, dmg: int) -> void:
	dir = direction
	damage = dmg

func _ready() -> void:
	sprite.flip_h = dir < 0
	sprite.modulate = Color(1.6, 1.4, 0.7)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var step := SPEED * dir * delta
	position.x += step
	_traveled += absf(step)
	if _traveled >= TRAVEL:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var id := area.get_instance_id()
	if _hit_ids.has(id):
		return
	_hit_ids[id] = true
	if area.has_method("on_strike"):
		area.on_strike()
	elif area.has_method("take_hit"):
		area.take_hit(damage, dir)