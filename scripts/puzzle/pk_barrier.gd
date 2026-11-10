extends StaticBody2D
## PKBarrier - dinding kristal per kolom; hanya kolom unik yang pecah (GDD 5.3, 4.3).
## Validasi dihitung dari data `rows` (unik & bukan NULL), bukan dari kunci jawaban.

@export var puzzle_id := "L2_P01"
@export var barrier_width := 3
@export var barrier_height := 5
@export var composite := false

var data: Dictionary = {}
var _solved := false
var _mistakes := 0
var _combo: Array = []
var _combo_deadline := 0

@onready var shape_node: CollisionShape2D = $CollisionShape2D
@onready var crystals: Node2D = $Crystals

func _ready() -> void:
	data = _load_puzzle()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(barrier_width * 16, barrier_height * 16)
	shape_node.shape = rect
	shape_node.position = Vector2(barrier_width * 8, -barrier_height * 8)
	_build_crystals()
	if GameState.solved_puzzles.has(puzzle_id):
		_solved = true
		shape_node.set_deferred("disabled", true)
		modulate = Color(1, 1, 1, 0.2)

func _load_puzzle() -> Dictionary:
	var f := FileAccess.open("res://data/puzzles/%s.json" % puzzle_id, FileAccess.READ)
	if f == null:
		push_warning("PKBarrier: puzzle %s tidak ada" % puzzle_id)
		return {}
	return JSON.parse_string(f.get_as_text())

func _build_crystals() -> void:
	var cols: Array = data.get("columns", [])
	var span := barrier_width * 16.0
	for i in cols.size():
		var c := Area2D.new()
		c.name = "Crystal_" + String(cols[i])
		c.collision_layer = 4
		c.collision_mask = 0
		c.add_to_group("pk_crystal")
		var s := Sprite2D.new()
		s.texture = load("res://assets/sprites/ui/crystal_column.png")
		s.scale = Vector2(0.9, 2.6)
		c.add_child(s)
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(14, 72)
		cs.shape = r
		c.add_child(cs)
		var l := Label.new()
		l.text = String(cols[i])
		l.position = Vector2(-12, -104)
		l.add_theme_font_size_override("font_size", 8)
		l.add_theme_color_override("font_color", Color(0.92, 0.97, 1))
		c.add_child(l)
		c.position = Vector2(span / cols.size() * (i + 0.5), -barrier_height * 8)
		var col_name := String(cols[i])
		c.area_entered.connect(func(_a): hit_column(col_name))
		crystals.add_child(c)

func hit_column(column: String) -> void:
	if _solved:
		return
	var rows: Array = data.get("rows", [])
	if not composite:
		if _is_unique([column], rows):
			_solve(column)
		else:
			_deflect(column)
		return
	var now := Time.get_ticks_msec()
	if _combo.size() == 1 and now > _combo_deadline:
		_combo.clear()
	if _combo.has(column):
		EventBus.message.emit("Kolom itu sudah dipukul. Pukul kolom lain dalam 2 detik.")
		return
	_combo.append(column)
	AudioManager.play_sfx("skill")
	if _combo.size() == 1:
		_combo_deadline = now + 2000
		EventBus.message.emit("Kristal %s terpukul. Butuh 1 kolom lagi (2 detik)." % column)
		return
	if _is_unique(_combo, rows):
		_solve("%s+%s" % _combo)
	else:
		_deflect(_combo[0])
		_combo.clear()

func _is_unique(cols: Array, rows: Array) -> bool:
	if rows.is_empty():
		return false
	var seen := {}
	for r in rows:
		var key := ""
		for c in cols:
			var v = r.get(c)
			if v == null:
				return false
			key += str(v) + "|"
		if seen.has(key):
			return false
		seen[key] = true
	return true

func _deflect(column: String) -> void:
	_mistakes += 1
	var ex: Dictionary = data.get("explanations", {})
	EventBus.message.emit("Bukan primary key - " + String(ex.get(column, "Duplicate key value.")))
	AudioManager.play_sfx("puzzle_wrong")
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1.5, 0.5, 0.5), 0.08)
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.22)

func _solve(column: String) -> void:
	_solved = true
	var ex: Dictionary = data.get("explanations", {})
	EventBus.message.emit("Benar! " + String(ex.get(column, "Primary key valid.")))
	AudioManager.play_sfx("puzzle_correct")
	shape_node.set_deferred("disabled", true)
	var stars := 3 if _mistakes == 0 else (2 if _mistakes <= 2 else 1)
	GameState.solve_puzzle(puzzle_id, stars, 120 if composite else 80)
	GameState.refresh_rank()
	if composite:
		for w in get_tree().get_nodes_in_group("warden"):
			w.stun(6.0)
	var t := create_tween()
	t.tween_property(crystals, "modulate", Color(1, 1, 1, 0), 0.3)
	t.parallel().tween_property(self, "modulate:a", 0.15, 0.3)
