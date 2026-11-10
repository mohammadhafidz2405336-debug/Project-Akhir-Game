extends Node
## Probe: (1) MULAI BARU, (2) buka puzzle & seret semua kartu ke kolom, (3) LANJUTKAN.

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var menu := get_tree().current_scene
	var play: Button = menu.get_node("Box/Play")
	var cont: Button = menu.get_node("Box/Continue")
	print("PROBE 1 cont.disabled=", cont.disabled, " (harus true)")

	_click(play.get_global_rect().get_center())
	await get_tree().create_timer(1.2).timeout
	print("PROBE 2 scene=", _scene(), " save=", SaveManager.has_save())

	var term: Node = null
	for n in get_tree().current_scene.find_children("*", "Area2D", true, false):
		if n.get_script() != null and "puzzle_terminal" in String(n.get_script().resource_path):
			term = n
			break
	print("PROBE 3 terminal=", term != null)
	if term == null:
		get_tree().quit(1)
		return

	term.interact(get_tree().get_first_node_in_group("player"))
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png("/workspace/probe_puzzle_open.png")

	var slots: Array = term.find_children("*", "Button", true, false).filter(
		func(b): return b.get_script() != null and "drop_slot" in String(b.get_script().resource_path))
	var cards: Array = term.find_children("*", "Button", true, false).filter(
		func(b): return b.get_script() != null and "drag_card" in String(b.get_script().resource_path))
	print("PROBE 4 slot=", slots.size(), " kartu=", cards.size())

	# simulasi drop: kirim payload ke slot yang kolomnya cocok
	for cd in cards:
		var pay: Dictionary = cd.payload
		for s in slots:
			if s.column == String(pay.get("column", "")) and not s.filled:
				s._drop_data(Vector2.ZERO, pay)
				break
	await get_tree().create_timer(0.8).timeout
	var terisi := 0
	for s in slots:
		if s.filled:
			terisi += 1
	print("PROBE 5 slot terisi=", terisi, "/", slots.size())
	print("PROBE 6 puzzle solved=", GameState.solved_puzzles.has("L1_P01"))
	get_viewport().get_texture().get_image().save_png("/workspace/probe_puzzle_done.png")

	await get_tree().create_timer(1.8).timeout
	print("PROBE 7 setelah selesai: paused=", get_tree().paused, " ui=", is_instance_valid(term._open_ui))

	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	await get_tree().create_timer(1.0).timeout
	menu = get_tree().current_scene
	cont = menu.get_node("Box/Continue")
	print("PROBE 8 cont.disabled=", cont.disabled, " (harus false)")
	_click(cont.get_global_rect().get_center())
	await get_tree().create_timer(1.2).timeout
	print("PROBE 9 scene=", _scene(), " player=", get_tree().get_first_node_in_group("player").global_position)
	get_tree().quit(0)

func _scene() -> String:
	var s := get_tree().current_scene
	return s.scene_file_path if s else "null"

func _click(pos: Vector2) -> void:
	var mv := InputEventMouseMotion.new()
	mv.position = pos
	mv.global_position = pos
	Input.parse_input_event(mv)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		e.position = pos
		e.global_position = pos
		Input.parse_input_event(e)