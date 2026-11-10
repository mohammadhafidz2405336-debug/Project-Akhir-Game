extends Node
## Autotest - smoke test otomatis (bukti "sudah dijalankan", bukan klaim).
## Jalankan: godot --headless --path . -- --autotest
## Memeriksa: menu, muat L1, gerak pemain, pickup, puzzle PK (valid + ditolak),
## Relation Bridge (valid + orphan), dan layar akhir. Cetak PASS/FAIL lalu keluar.

var fails: Array[String] = []
var passes := 0

func _ready() -> void:
	await get_tree().process_frame
	print("AUTOTEST mulai")
	await _run()
	print("AUTOTEST selesai: %d pass, %d fail" % [passes, fails.size()])
	for f in fails:
		print("  FAIL ", f)
	get_tree().quit(1 if fails.size() > 0 else 0)

func _check(ok: bool, label: String) -> void:
	if ok:
		passes += 1
		print("  PASS ", label)
	else:
		fails.append(label)
		print("  FAIL ", label)

func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame

func _run() -> void:
	# 1. menu -> mulai run -> L1
	RoomManager.start_new_run()
	await _frames(30)
	var level := get_tree().current_scene
	_check(level != null and String(level.scene_file_path).contains("level1"), "L1 termuat dari Start")
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	_check(player != null, "node Player ada di scene")
	if player == null:
		return

	# 2. pemain berdiri di lantai (tidak jatuh menembus tilemap)
	await _frames(40)
	_check(player.is_on_floor(), "Player berdiri di lantai TileMapLayer")
	var y_before := player.global_position.y

	# 3. gerak kanan
	var x0 := player.global_position.x
	Input.action_press("move_right")
	await _frames(40)
	Input.action_release("move_right")
	_check(player.global_position.x > x0 + 20.0, "Player bergerak ke kanan (A/D)")
	_check(absf(player.global_position.y - y_before) < 40.0, "Player tidak jatuh saat berjalan")

	# 4. lompat
	Input.action_press("jump")
	await _frames(3)
	Input.action_release("jump")
	await _frames(10)
	_check(player.velocity.y < 0.0 or player.global_position.y < y_before - 8.0, "Player melompat (Space)")

	# 5. pickup: pindahkan pemain ke Data Fragment pertama, tunggu terambil
	var frag0 := GameState.fragments
	var pickup: Node = get_tree().get_first_node_in_group("pickup")
	_check(pickup != null, "Pickup ada di level")
	if pickup != null:
		player.global_position = pickup.global_position
		await _frames(12)
		_check(GameState.fragments > frag0, "Data Fragment terambil (fragments %d -> %d)" % [frag0, GameState.fragments])

	# 6. puzzle PK L2_P01: kolom duplikat ditolak, NIM diterima
	var barrier: Node = load("res://scenes/puzzle/pk_barrier.tscn").instantiate()
	barrier.puzzle_id = "L2_P01"
	add_child(barrier)
	await _frames(4)
	barrier.hit_column("Nama")
	await _frames(2)
	_check(not GameState.solved_puzzles.has("L2_P01"), "PKBarrier menolak kolom duplikat (Nama)")
	barrier.hit_column("NIM")
	await _frames(2)
	_check(GameState.solved_puzzles.has("L2_P01"), "PKBarrier menerima primary key unik (NIM)")

	# 7. PK L2_P02: NIK unik tapi mengandung NULL -> ditolak (entity integrity)
	var b2: Node = load("res://scenes/puzzle/pk_barrier.tscn").instantiate()
	b2.puzzle_id = "L2_P02"
	add_child(b2)
	await _frames(4)
	b2.hit_column("NIK")
	await _frames(2)
	_check(not GameState.solved_puzzles.has("L2_P02"), "NIK dengan NULL ditolak (entity integrity)")
	b2.hit_column("KodePegawai")
	await _frames(2)
	_check(GameState.solved_puzzles.has("L2_P02"), "KodePegawai diterima sebagai primary key")

	# 8. Relation Bridge: FK 2 -> PK 2 valid, FK 7 -> PK 1,2,3 gagal (orphan)
	var caster: Node = player.get_node("SkillCaster")
	var fk: Node = load("res://scenes/puzzle/anchor.tscn").instantiate()
	fk.anchor_type = "fk"
	fk.anchor_value = "2"
	fk.anchor_label = "MK01.id_dosen"
	add_child(fk)
	var pk: Node = load("res://scenes/puzzle/anchor.tscn").instantiate()
	pk.anchor_type = "pk"
	pk.anchor_value = "2"
	add_child(pk)
	await _frames(4)
	fk.global_position = player.global_position
	pk.global_position = player.global_position + Vector2(60, 0)
	caster.toggle(fk)
	caster.toggle(pk)
	await _frames(4)
	var bridges := get_tree().get_nodes_in_group("bridge")
	_check(bridges.size() >= 1, "Relation Bridge terbentuk untuk FK yang valid")
	var orphans0 := get_tree().get_nodes_in_group("orphan_glitch").size()
	var fk2: Node = load("res://scenes/puzzle/anchor.tscn").instantiate()
	fk2.anchor_type = "fk"
	fk2.anchor_value = "7"
	fk2.anchor_label = "MK03.id_dosen"
	add_child(fk2)
	await _frames(2)
	fk2.global_position = player.global_position
	pk.global_position = player.global_position + Vector2(60, 0)
	caster.toggle(fk2)
	caster.toggle(pk)
	await _frames(6)
	_check(get_tree().get_nodes_in_group("orphan_glitch").size() > orphans0,
		"FK tidak valid -> Orphan Glitch muncul (referential integrity)")

	# 9. HUD & atribut bereaksi
	GameState.add_fragments(10)
	await _frames(2)
	_check(GameState.fragments >= 10, "Jumlah Data Fragments bertambah")


	# 11. SkillPedestal membuka skill
	var ped: Node = load("res://scenes/puzzle/skill_pedestal.tscn").instantiate()
	ped.skill = "scan"
	add_child(ped)
	await _frames(4)
	ped.global_position = player.global_position
	await _frames(6)
	ped.interact(player)
	await _frames(4)
	_check(SkillManager.is_unlocked("scan"), "SkillPedestal membuka Data Scan")

	# 12. SyncPoint menyimpan checkpoint
	var sp: Node = load("res://scenes/puzzle/sync_point.tscn").instantiate()
	add_child(sp)
	sp.global_position = player.global_position
	await _frames(6)
	_check(RoomManager.last_checkpoint.distance_to(sp.global_position) < 40.0,
		"SyncPoint menyimpan checkpoint posisi")

	# 13. ExitMarker menolak keluar tanpa Schema Key
	GameState.schema_keys.clear()
	var ex: Node = load("res://scenes/puzzle/exit_marker.tscn").instantiate()
	add_child(ex)
	ex.global_position = player.global_position
	await _frames(10)
	_check(String(get_tree().current_scene.scene_file_path).contains("level1"),
		"ExitMarker terkunci tanpa Schema Key")

	# 14. layar Menang/Kalah
	RoomManager.goto_end_session(true)
	await _frames(20)
	_check(String(get_tree().current_scene.scene_file_path).contains("end_session"), "Layar End Session terbuka")
