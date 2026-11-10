extends StaticBody2D
## Gate - pintu yang terbuka bila puzzle terkait selesai (atau arena tertutup).

@export var puzzle_id := ""
@export var closes := false

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 48)
	shape_node.shape = rect
	shape_node.position = Vector2(0, -24)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(64, 0, 16, 16)
	sprite.texture = load("res://assets/tilesets/%s.png" % _region())
	sprite.scale = Vector2(1, 3)
	if not closes and puzzle_id != "" and GameState.solved_puzzles.has(puzzle_id):
		_open()

func _region() -> String:
	match RoomManager.current_level:
		"L2": return "l2"
		"L3": return "l3"
	return "l1"

func _open() -> void:
	shape_node.set_deferred("disabled", true)
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0.15), 0.3)

func open_gate() -> void:
	_open()

func close_gate() -> void:
	shape_node.set_deferred("disabled", false)
	modulate = Color(1, 1, 1, 1)