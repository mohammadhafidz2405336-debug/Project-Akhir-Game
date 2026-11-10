extends Area2D
## NullOrb - proyektil boss. Bergerak lurus sampai menabrak dinding/pemain.

var direction := Vector2.LEFT
var speed := 110.0
var damage := 1
var owner_group := "boss_orb"

func _ready() -> void:
	add_to_group("boss_orb")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func hit_damage() -> int:
	return damage

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.has_method("hurt"):
		area.hurt(damage, global_position)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("hurt"):
		body.hurt(damage, global_position)
		queue_free()
	elif body is StaticBody2D:
		queue_free()
