extends Node
## SkillCaster - pencarian anchor dan pembentukan Relation Bridge (GDD 3.3).

const BRIDGE := preload("res://scenes/skills/bridge.tscn")
const MAX_LINKS := 2
const LINK_RANGE := 128.0

var pending_fk: Node = null
var active_bridges: Array = []

func reset() -> void:
	pending_fk = null
	for b in active_bridges:
		if is_instance_valid(b):
			b.queue_free()
	active_bridges.clear()

## Dipanggil player saat tombol 5 ditekan bila ada anchor terdekat.
func toggle(anchor: Node) -> void:
	if anchor == null:
		EventBus.message.emit("Tidak ada anchor dalam jangkauan (maks 128 px).")
		return
	if anchor.is_in_group("pk_anchor"):
		_finish_link(anchor)
		return
	if pending_fk == anchor:
		anchor.set_selected(false)
		pending_fk = null
		EventBus.message.emit("Anchor FK dilepas.")
		return
	if pending_fk != null and is_instance_valid(pending_fk):
		pending_fk.set_selected(false)
	pending_fk = anchor
	anchor.set_selected(true)
	EventBus.message.emit("FK %s dipilih. Dekati PK Anchor tujuan." % anchor.value_text())

func _finish_link(pk: Node) -> void:
	if pending_fk == null or not is_instance_valid(pending_fk):
		EventBus.message.emit("Pilih FK Anchor lebih dulu.")
		return
	if pending_fk.global_position.distance_to(pk.global_position) > LINK_RANGE:
		EventBus.message.emit("Jarak anchor terlalu jauh (maks 128 px).")
		return
	var ok: bool = pk.accepts(pending_fk.value_text())
	if not ok:
		EventBus.message.emit("Foreign key constraint fails: parent row not found.")
		AudioManager.play_sfx("puzzle_wrong")
		_spawn_orphan(pending_fk.global_position)
		pending_fk.set_selected(false)
		pending_fk = null
		return
	if active_bridges.size() >= MAX_LINKS:
		var old = active_bridges.pop_front()
		if is_instance_valid(old):
			old.dissolve()
	var bridge := BRIDGE.instantiate()
	bridge.setup(pending_fk.global_position, pk.global_position)
	get_tree().current_scene.add_child(bridge)
	active_bridges.append(bridge)
	AudioManager.play_sfx("bridge")
	EventBus.message.emit("Relasi valid: %s -> %s. Jembatan aktif 20 detik." %
		[pending_fk.value_text(), pk.value_text()])
	pending_fk.set_selected(false)
	pending_fk = null
	pk.on_linked()

func _spawn_orphan(pos: Vector2) -> void:
	var scn := preload("res://scenes/enemies/orphan_glitch.tscn")
	var e := scn.instantiate()
	e.global_position = pos
	get_tree().current_scene.add_child(e)

func _process(_delta: float) -> void:
	active_bridges = active_bridges.filter(func(b): return is_instance_valid(b))
