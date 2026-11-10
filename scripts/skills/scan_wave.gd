extends Area2D
## ScanWave - Data Scan: gelombang radius 96 px, objek `scannable` terlihat 8 detik.

const RADIUS := 96.0
const DURATION := 0.4

var _t := 0.0
var revealed: Array = []

@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	AudioManager.play_sfx("skill")
	var c := CircleShape2D.new()
	c.radius = 8.0
	shape.shape = c
	for n in get_tree().get_nodes_in_group("scannable"):
		if global_position.distance_to(n.global_position) <= RADIUS:
			if n.has_method("reveal"):
				n.reveal(8.0)
				revealed.append(n)
	EventBus.message.emit("Data Scan: %d objek terdeteksi (atribut/record terlihat)." % revealed.size())

func _process(delta: float) -> void:
	_t += delta
	var r := lerpf(8.0, RADIUS, clampf(_t / DURATION, 0.0, 1.0))
	var c := shape.shape as CircleShape2D
	if c != null:
		c.radius = r
	if _t >= DURATION:
		queue_free()
