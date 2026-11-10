extends Area2D
## SyncPoint - titik sinkronisasi: simpan game, pulihkan Health/Energy (GDD 5.3).

var _used := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	add_to_group("scannable")
	sprite.texture = load("res://assets/sprites/ui/sync_point.png")
	label.visible = false
	label.text = "Sync"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _used:
		return
	_used = true
	body.set_checkpoint(global_position + Vector2(0, -8))
	GameState.set_health(GameState.health_max)
	GameState.set_energy(GameState.energy_max)
	SaveManager.save_game()
	AudioManager.play_sfx("puzzle_correct")
	EventBus.message.emit("Sync Point aktif: Health & Energy pulih, progres disimpan.")
	label.visible = true

func reveal(seconds: float) -> void:
	label.visible = true
	var t := create_tween()
	t.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(seconds)