extends Area2D
## ExitMarker - pintu keluar level. target_room disimpan agar Minggu 3 mudah
## menyambungkan ke Hub (GDD 2.2 catatan) tanpa menulis ulang scene.

@export var target_room := "level_select"

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	label.text = "KELUAR"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameState.schema_keys.is_empty():
		EventBus.message.emit("Schema Gate terkunci: kalahkan Guardian untuk Schema Key.")
		return
	AudioManager.play_sfx("victory")
	GameState.complete_level(RoomManager.current_level)
	SaveManager.save_game()
	RoomManager.goto_level_select()