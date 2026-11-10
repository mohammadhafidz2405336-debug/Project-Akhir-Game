extends StaticBody2D
## SecretWall - dinding yang hanya terbuka setelah dipindai Data Scan (GDD 4.2).

@export var wall_width := 2
@export var wall_height := 3

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var _opened := false
var _timer: SceneTreeTimer = null

func _ready() -> void:
	add_to_group("scannable")
	var rect := RectangleShape2D.new()
	rect.size = Vector2(wall_width * 16, wall_height * 16)
	shape_node.shape = rect
	shape_node.position = Vector2(wall_width * 8, -wall_height * 8)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(64, 16, 16, 16)  # tile dinding rahasia di atlas
	sprite.texture = load("res://assets/tilesets/%s.png" % _region())
	sprite.scale = Vector2(wall_width, wall_height)

func _region() -> String:
	match RoomManager.current_level:
		"L2": return "l2"
		"L3": return "l3"
	return "l1"

func reveal(seconds: float) -> void:
	_opened = true
	shape_node.set_deferred("disabled", true)
	sprite.modulate = Color(0.6, 1.3, 1.2, 0.45)
	EventBus.message.emit("Dinding data terbuka: jalan rahasia ditemukan.")
	_timer = get_tree().create_timer(seconds)
	await _timer.timeout
	if is_instance_valid(self) and _opened:
		sprite.modulate = Color(0.8, 1, 1, 0.75)