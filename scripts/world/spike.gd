extends Area2D
## Spike - hazard dasar (layer 8). Menyentuh pemain = -1 health.

@export var damage := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("hurt"):
		body.hurt(damage, global_position)
