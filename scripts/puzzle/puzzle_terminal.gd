extends Area2D
## PuzzleTerminal - terminal puzzle berbasis UI (GDD 5.3).
## Tipe: column_match (L1, kartu -> slot kolom) dan fk_fix (L3, perbaiki FK).

@export var puzzle_id := "L1_P01"

var data: Dictionary = {}
var _open_ui: CanvasLayer = null
var _can_interact := true

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	sprite.texture = load("res://assets/sprites/ui/terminal.png")
	label.text = "Tekan E"
	body_entered.connect(func(b):
		if b.is_in_group("player"):
			b.interacting = self
			label.visible = true)
	body_exited.connect(func(b):
		if b.is_in_group("player"):
			b.interacting = null
			label.visible = false)
	var f := FileAccess.open("res://data/puzzles/%s.json" % puzzle_id, FileAccess.READ)
	if f != null:
		data = JSON.parse_string(f.get_as_text())
	if GameState.solved_puzzles.has(puzzle_id):
		label.text = "SELESAI"

func interact(player: Node) -> void:
	if _open_ui != null:
		return
	player.interacting = null
	label.visible = false
	_open(player)

func _open(player: Node) -> void:
	get_tree().paused = true
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_open_ui = layer

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.06, 0.82)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	var panel := PanelContainer.new()
	panel.position = Vector2(90, 60)
	panel.custom_minimum_size = Vector2(780, 400)
	root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var title := Label.new()
	title.text = "%s — %s" % [String(data.get("table", "")), puzzle_id]
	title.add_theme_font_size_override("font_size", 12)
	box.add_child(title)

	var instr := Label.new()
	instr.text = String(data.get("instruksi", "Pilih jawaban yang benar."))
	instr.add_theme_font_size_override("font_size", 8)
	instr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(instr)

	var table_label := Label.new()
	table_label.text = _render_table()
	table_label.add_theme_font_size_override("font_size", 8)
	box.add_child(table_label)

	var feedback := Label.new()
	feedback.text = "Pilih jawaban."
	feedback.add_theme_font_size_override("font_size", 8)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(feedback)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)

	if String(data.get("type", "")) == "column_match":
		_build_column_match(row, feedback, player)
	else:
		_build_fk_fix(row, feedback, player)

	var close := Button.new()
	close.text = "Tutup (Esc)"
	close.add_theme_font_size_override("font_size", 8)
	close.pressed.connect(_close)
	box.add_child(close)

func _render_table() -> String:
	var cols: Array = data.get("columns", [])
	var rows: Array = data.get("rows", [])
	var out := ""
	for c in cols:
		out += String(c) + " | "
	out += "\n"
	for r in rows:
		for c in cols:
			out += str(r.get(c)) + " | "
		out += "\n"
	return out

func _build_column_match(parent: HBoxContainer, feedback: Label, player: Node) -> void:
	var cols: Array = data.get("columns", [])
	var cards: Array = data.get("cards", [])
	var slots := {}
	var card_state := {}
	var selected: Array = [null]
	var wrong := [0]
	var ui := self

	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 10)
	parent.add_child(grid)
	for c in cols:
		var col_box := VBoxContainer.new()
		var head := Label.new()
		head.text = "[%s]" % c
		head.add_theme_font_size_override("font_size", 8)
		col_box.add_child(head)
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(150, 30)
		slot.text = "(kosong)"
		slot.add_theme_font_size_override("font_size", 8)
		slot.disabled = true
		col_box.add_child(slot)
		grid.add_child(col_box)
		slots[c] = slot
		slot.pressed.connect(func():
			if selected[0] == null:
				feedback.text = "Pilih kartu nilai lebih dulu."
				return
			var card: Dictionary = selected[0]
			if String(card["column"]) != String(c):
				wrong[0] += 1
				feedback.text = "Salah: nilai '%s' bukan bagian domain kolom %s." % [card["value"], c]
				AudioManager.play_sfx("puzzle_wrong")
				var t := ui.create_tween()
				t.tween_property(slot, "modulate", Color(2, 0.5, 0.5), 0.08)
				t.tween_property(slot, "modulate", Color(1, 1, 1), 0.2)
				return
			slot.text = String(card["value"])
			slot.disabled = false
			slot.modulate = Color(0.6, 1.4, 0.7)
			feedback.text = "Benar: %s masuk domain kolom %s." % [card["value"], c]
			AudioManager.play_sfx("puzzle_correct")
			card_state[card["value"]] = true
			selected[0] = null
			var missing := false
			for cd in cards:
				if not card_state.has(cd["value"]):
					missing = true
			if not missing:
				var stars := 3 if wrong[0] == 0 else (2 if wrong[0] <= 2 else 1)
				GameState.solve_puzzle(String(data["id"]), stars, 80)
				GameState.refresh_rank()
				feedback.text = "Selesai! Tabel %s utuh. Bintang: %d" % [String(data["table"]), stars]
				AudioManager.play_sfx("puzzle_correct")
				get_tree().create_timer(1.4, true).timeout.connect(_close))

	var card_row := HBoxContainer.new()
	card_row.add_theme_constant_override("separation", 6)
	parent.add_child(card_row)
	for cd in cards:
		var b := Button.new()
		b.text = String(cd["value"])
		b.add_theme_font_size_override("font_size", 8)
		b.custom_minimum_size = Vector2(110, 28)
		card_row.add_child(b)
		b.pressed.connect(func():
			selected[0] = cd
			feedback.text = "Dipilih: %s. Klik slot kolom yang tepat." % cd["value"]
			AudioManager.play_sfx("ui_click"))

func _build_fk_fix(parent: HBoxContainer, feedback: Label, player: Node) -> void:
	var parent_rows: Array = data.get("parent_rows", [])
	var info := Label.new()
	info.text = "%s: %s" % [String(data.get("parent_table", "")), str(parent_rows)]
	info.add_theme_font_size_override("font_size", 8)
	parent.add_child(info)
	var row := HBoxContainer.new()
	parent.add_child(row)
	var options := [1, 2, 3, "NULL"]
	for v in options:
		var b := Button.new()
		b.text = str(v)
		b.add_theme_font_size_override("font_size", 8)
		b.custom_minimum_size = Vector2(90, 28)
		row.add_child(b)
		b.pressed.connect(func(): _resolve_fk(v, feedback, player))

func _resolve_fk(value, feedback: Label, _player: Node) -> void:
	var valid: Array = data.get("valid_values", [])
	var is_valid := false
	for v in valid:
		if (v == null and String(value) == "NULL") or str(v) == str(value):
			is_valid = true
	var ex: Dictionary = data.get("explanations", {})
	if not is_valid:
		feedback.text = String(ex.get("invalid", "FK tidak valid."))
		AudioManager.play_sfx("puzzle_wrong")
		return
	feedback.text = String(ex.get("null" if String(value) == "NULL" else "valid", "Benar."))
	AudioManager.play_sfx("puzzle_correct")
	var new_value := "NULL" if String(value) == "NULL" else str(value)
	for a in get_tree().get_nodes_in_group("fk_anchor"):
		if a.has_method("set_fk_value"):
			a.set_fk_value(new_value)
	for e in get_tree().get_nodes_in_group("orphan_glitch"):
		if is_instance_valid(e):
			e.queue_free()
	GameState.solve_puzzle(String(data["id"]), 3 if new_value != "NULL" else 2, 80)
	GameState.refresh_rank()
	EventBus.message.emit("Foreign key diperbaiki: MK03.id_dosen = %s" % new_value)
	get_tree().create_timer(1.2, true).timeout.connect(_close)

func _close() -> void:
	if _open_ui != null:
		_open_ui.queue_free()
		_open_ui = null
	get_tree().paused = false
