extends Area2D
## OrphanGlitch - hilang setelah 15 detik; dibersihkan saat link valid dibuat.

@export var damage := 1

var _life := 15.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("orphan_glitch")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("hurt"):
		body.hurt(damage, global_position)

func take_hit(_amount: int, _dir: int = 1) -> void:
	queue_free()

func hit_damage() -> int:
	return damage
