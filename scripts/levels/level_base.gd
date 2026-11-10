extends Node2D
## LevelBase - memuat data level ASCII (data/levels/<id>.json), mengecat TileMapLayer,
## membuat RoomBounds, dan meng-instance entitas nyata (GDD 5.3). Tiga scene level
## hanya menetapkan `level_id`; geometri hidup di data/ agar mudah diverifikasi.

const TILE := 16
const SOLID_ATLAS := {"#": Vector2i(0, 1), "=": Vector2i(5, 0), "G": Vector2i(5, 1)}

@export var level_id := "L1"

var data: Dictionary = {}
var room_bounds: Array = []
var current_room := ""
var player: Node2D = null
var _arena_gate: Node = null

@onready var solid: TileMapLayer = $Solid
@onready var decor: TileMapLayer = $Decor
@onready var rooms: Node2D = $Rooms
@onready var entities: Node2D = $Entities
@onready var player_node: Node = $Player
@onready var hud: CanvasLayer = $HUD
@onready var info: Label = $Info

func _ready() -> void:
	RoomManager.current_level = level_id
	RoomManager.level_scene = self
	data = _load_data()
	_paint()
	_build_rooms()
	_spawn_entities()
	player = player_node
	var sp: Dictionary = data.get("spawn", {})
	player.global_position = _tile_to_world(int(sp.get("x", 3)), int(sp.get("y", 15)))
	RoomManager.set_checkpoint(level_id, player.global_position)
	AudioManager.play_music("level")
	await get_tree().process_frame
	if not room_bounds.is_empty():
		var first: Dictionary = room_bounds[0]
		_enter_room(first)
		_apply_room(String(first["id"]))
	_show_hint(String(data.get("nama", level_id)))

func _load_data() -> Dictionary:
	var path := "res://data/levels/%s.json" % level_id
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("LevelBase: %s tidak ditemukan" % path)
		return {}
	return JSON.parse_string(f.get_as_text())

## ---------- tilemap ----------
func _paint() -> void:
	var map: Array = data.get("map", [])
	for y in map.size():
		var row: String = map[y]
		for x in row.length():
			var ch := row[x]
			if ch == ".":
				if y % 3 == 0 and (x + y) % 7 == 0:
					decor.set_cell(Vector2i(x, y), 0, Vector2i(7, 1))
				continue
			if ch == "G":
				solid.set_cell(Vector2i(x, y), 0, Vector2i(5, 1))
				_make_ghost(Vector2i(x, y))
			elif ch == "=":
				solid.set_cell(Vector2i(x, y), 0, Vector2i(5, 0))
			else:
				solid.set_cell(Vector2i(x, y), 0, _solid_variant(map, x, y))

func _solid_variant(map: Array, x: int, y: int) -> Vector2i:
	var up := _solid_at(map, x, y - 1)
	var dn := _solid_at(map, x, y + 1)
	var lf := _solid_at(map, x - 1, y)
	var rt := _solid_at(map, x + 1, y)
	if not up and not lf:
		return Vector2i(0, 0)
	if not up and not rt:
		return Vector2i(2, 0)
	if not up:
		return Vector2i(1, 0)
	if not lf:
		return Vector2i(0, 1)
	if not rt:
		return Vector2i(2, 1)
	if not dn:
		return Vector2i(1, 2)
	return Vector2i(1, 1)

func _solid_at(map: Array, x: int, y: int) -> bool:
	if y < 0 or y >= map.size():
		return true
	var row: String = map[y]
	if x < 0 or x >= row.length():
		return true
	return row[x] == "#"

## Platform hantu: visual sudah ada di tilemap, collision baru aktif setelah dipindai.
func _make_ghost(cell: Vector2i) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.set_meta("ghost", true)
	var cs := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE, TILE)
	cs.shape = rect
	body.add_child(cs)
	body.position = _tile_to_world(cell.x, cell.y) + Vector2(0, TILE * 0.5)
	body.add_to_group("scannable")
	body.add_to_group("ghost_platform")
	entities.add_child(body)

## ---------- room & kamera ----------
func _build_rooms() -> void:
	for r in data.get("rooms", []):
		var area := Area2D.new()
		area.name = String(r["id"])
		area.collision_layer = 0
		area.collision_mask = 2
		var cs := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		var x0: int = int(r["x0"])
		var x1: int = int(r["x1"])
		rect.size = Vector2((x1 - x0 + 1) * TILE, int(data.get("height", 20)) * TILE)
		cs.shape = rect
		area.add_child(cs)
		area.position = Vector2((x0 + x1 + 1) * TILE * 0.5, rect.size.y * 0.5)
		area.body_entered.connect(func(b):
			if b.is_in_group("player"):
				_enter_room(r))
		rooms.add_child(area)
		room_bounds.append({"id": String(r["id"]), "x0": x0, "x1": x1, "nama": String(r["nama"])})

func _enter_room(r: Dictionary) -> void:
	if current_room == String(r["id"]):
		return
	current_room = String(r["id"])
	RoomManager.enter_room(current_room)
	_apply_room(current_room)
	var hint := String(r.get("hint", ""))
	if hint != "":
		EventBus.message.emit(hint)

func _apply_room(id: String) -> void:
	for r in room_bounds:
		if String(r["id"]) == id:
			_set_camera_limits(int(r["x0"]), int(r["x1"]))
			return

func _set_camera_limits(x0: int, x1: int) -> void:
	var cam: Camera2D = player_node.get_node_or_null("Camera2D")
	if cam == null:
		return
	cam.limit_left = x0 * TILE
	cam.limit_right = (x1 + 1) * TILE
	cam.limit_top = 0
	cam.limit_bottom = int(data.get("height", 20)) * TILE
	cam.reset_smoothing()

## ---------- entitas ----------
func _spawn_entities() -> void:
	for e in data.get("entities", []):
		var node := _build_entity(e)
		if node == null:
			continue
		entities.add_child(node)
		node.global_position = _tile_to_world(int(e["x"]), int(e["y"])) \
			+ Vector2(0, int(e.get("dy", 0)) * TILE)
		if String(e["type"]) == "gate" and bool(e.get("closes", false)):
			_arena_gate = node
	for h in data.get("hints", []):
		var l := Label.new()
		l.text = " " + String(h["text"]) + " "
		l.add_theme_font_size_override("font_size", 8)
		l.add_theme_color_override("font_color", Color(0.55, 0.95, 0.9))
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size = Vector2(int(h.get("w", 64)) * TILE, 44)
		l.position = _tile_to_world(int(h["x"]), int(h["y"]))
		entities.add_child(l)
	for g in get_tree().get_nodes_in_group("guardian"):
		g.died.connect(_on_guardian_died)

func _build_entity(e: Dictionary) -> Node:
	match String(e["type"]):
		"pickup":
			var p := preload("res://scenes/items/pickup.tscn").instantiate()
			p.kind = String(e.get("kind", "fragment"))
			p.collectible_id = String(e.get("cid", ""))
			p.amount = int(e.get("amount", 1))
			return p
		"enemy":
			var en := _enemy_scene(String(e.get("kind", "glitch_blob"))).instantiate()
			if e.has("guardian"):
				en.is_guardian = true
			if e.has("split"):
				en.split_on_death = bool(e["split"])
			if e.has("key"):
				en.drop_key = String(e["key"])
			return en
		"boss":
			var b := preload("res://scenes/enemies/null_sovereign.tscn").instantiate()
			b.defeated.connect(_on_boss_defeated)
			return b
		"pedestal":
			var pd := preload("res://scenes/puzzle/skill_pedestal.tscn").instantiate()
			pd.skill = String(e.get("skill", "scan"))
			return pd
		"terminal", "fk_fix_terminal":
			var t := preload("res://scenes/puzzle/puzzle_terminal.tscn").instantiate()
			t.puzzle_id = String(e.get("puzzle", "L1_P01"))
			return t
		"pk_barrier":
			var pb := preload("res://scenes/puzzle/pk_barrier.tscn").instantiate()
			pb.puzzle_id = String(e.get("puzzle", "L2_P01"))
			pb.barrier_width = int(e.get("w", 3))
			pb.barrier_height = int(e.get("h", 5))
			pb.composite = bool(e.get("composite", false))
			return pb
		"pk_anchor", "fk_anchor":
			var a := preload("res://scenes/puzzle/anchor.tscn").instantiate()
			a.anchor_type = "pk" if String(e["type"]) == "pk_anchor" else "fk"
			a.anchor_value = String(e.get("value", "1"))
			a.anchor_label = String(e.get("label", "id_dosen"))
			if e.has("accepts"):
				a.accepts_values = e["accepts"]
			return a
		"sync_point":
			return preload("res://scenes/puzzle/sync_point.tscn").instantiate()
		"secret_wall":
			var sw := preload("res://scenes/puzzle/secret_wall.tscn").instantiate()
			sw.wall_width = int(e.get("w", 2))
			sw.wall_height = int(e.get("h", 3))
			return sw
		"gate":
			var gt := preload("res://scenes/puzzle/gate.tscn").instantiate()
			gt.puzzle_id = String(e.get("puzzle", ""))
			gt.closes = bool(e.get("closes", false))
			return gt
		"exit_marker":
			var ex := preload("res://scenes/puzzle/exit_marker.tscn").instantiate()
			ex.target_room = String(e.get("target", "level_select"))
			return ex
		"spike":
			return preload("res://scenes/world/spike.tscn").instantiate()
	return null

func _enemy_scene(kind: String) -> PackedScene:
	match kind:
		"duplicate_slime": return preload("res://scenes/enemies/duplicate_slime.tscn")
		"orphan_glitch": return preload("res://scenes/enemies/orphan_glitch.tscn")
		"duplicate_golem": return preload("res://scenes/enemies/duplicate_golem.tscn")
		"composite_warden": return preload("res://scenes/enemies/composite_warden.tscn")
	return preload("res://scenes/enemies/glitch_blob.tscn")

func _on_guardian_died(_kind: String, _pos: Vector2) -> void:
	EventBus.message.emit("Guardian tumbang. Schema Key jatuh - ambil, lalu menuju pintu keluar.")

func _on_boss_defeated(_id: String) -> void:
	EventBus.message.emit("Layar Menang dibuka.")

func _tile_to_world(x: int, y: int) -> Vector2:
	return Vector2(x * TILE + TILE * 0.5, y * TILE)

func _show_hint(text: String) -> void:
	info.text = " %s " % text
	var t := create_tween()
	t.tween_property(info, "modulate:a", 0.0, 1.0).set_delay(3.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pm := get_node_or_null("PauseMenu")
		if pm != null and pm.has_method("toggle"):
			pm.toggle()
	elif event.is_action_pressed("journal"):
		EventBus.message.emit("Journal: %d Ancient Record terkumpul." % GameState.ancient_records.size())
