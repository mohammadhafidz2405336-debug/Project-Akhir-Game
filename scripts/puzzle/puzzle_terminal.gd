extends Area2D

## PuzzleTerminal - terminal puzzle berbasis UI (GDD 5.3).

@export var puzzle_id := "L1_P01"

var data: Dictionary = {}
var _open_ui: CanvasLayer = null
var _feedback_node: Label = null
var _card_total := 0
var _placed_count := 0
var _wrong_count := 0

## State untuk column_match
var _slots := {}
var _filled := {}
var _card_used := {}

func _ready() -> void:
	var sprite: Sprite2D = $Sprite2D
	sprite.texture = load("res://assets/sprites/ui/terminal.png")
	var label: Label = $Label
	label.text = "Tekan E"
	body_entered.connect(func(b: Node):
		if b.is_in_group("player"):
			b.interacting = self
			label.visible = true
	)
	body_exited.connect(func(b: Node):
		if b.is_in_group("player"):
			b.interacting = null
			label.visible = false
	)
	var f := FileAccess.open("res://data/puzzles/%s.json" % puzzle_id, FileAccess.READ)
	if f != null:
		data = JSON.parse_string(f.get_as_text())
	if GameState.solved_puzzles.has(puzzle_id):
		label.text = "SELESAI"

func interact(player: Node) -> void:
	if _open_ui != null:
		return
	$Label.visible = false
	_open(player)

func _input(event: InputEvent) -> void:
	if _open_ui == null:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()

func _open(player: Node) -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	panel.position = Vector2(70, 30)
	var sbp := StyleBoxFlat.new()
	sbp.bg_color = Color(0.08, 0.10, 0.12)
	sbp.set_border_width_all(2)
	sbp.border_color = Color(0.3, 0.35, 0.45)
	sbp.corner_radius_top_left = 8
	sbp.corner_radius_top_right = 8
	sbp.corner_radius_bottom_left = 8
	sbp.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sbp)
	root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(720, 560)
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# ---- title ----
	var title := Label.new()
	title.text = "%s — %s" % [String(data.get("table", "")), puzzle_id]
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	vbox.add_child(title)

	# ---- instruksi ----
	var instr := Label.new()
	instr.text = String(data.get("instruksi", "Seret setiap nilai ke kolom yang domainnya sesuai."))
	instr.add_theme_font_size_override("font_size", 14)
	instr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instr.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	vbox.add_child(instr)

	# ---- data card ----
	var data_card := PanelContainer.new()
	var sbc := StyleBoxFlat.new()
	sbc.bg_color = Color(0.07, 0.09, 0.11)
	sbc.set_border_width_all(2)
	sbc.border_color = Color(0.2, 0.25, 0.3)
	sbc.corner_radius_top_left = 6
	sbc.corner_radius_top_right = 6
	sbc.corner_radius_bottom_left = 6
	sbc.corner_radius_bottom_right = 6
	data_card.add_theme_stylebox_override("panel", sbc)
	vbox.add_child(data_card)

	var dv := VBoxContainer.new()
	dv.add_theme_constant_override("separation", 4)
	data_card.add_child(dv)

	# header baris
	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 2)
	dv.add_child(header_row)
	for c in data.get("columns", []):
		var hlbl := Label.new()
		hlbl.text = "[%s]" % c
		hlbl.add_theme_font_size_override("font_size", 12)
		hlbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.85))
		hlbl.custom_minimum_size = Vector2(180, 28)
		header_row.add_child(hlbl)

	# baris data (tampilkan paling atas dulu)
	var rows: Array = data.get("rows", [])
	for i in range(rows.size() - 1, -1, -1):
		var r: Dictionary = rows[i]
		var row_hbox := HBoxContainer.new()
		row_hbox.add_theme_constant_override("separation", 2)
		dv.add_child(row_hbox)
		for c in data.get("columns", []):
			var vlbl := Label.new()
			vlbl.text = String(r.get(c, ""))
			vlbl.add_theme_font_size_override("font_size", 11)
			vlbl.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
			vlbl.custom_minimum_size = Vector2(150, 24)
			row_hbox.add_child(vlbl)

	# ---- area jawaban ----
	var ans_label := Label.new()
	ans_label.text = "Jawaban:"
	ans_label.add_theme_font_size_override("font_size", 12)
	ans_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
	vbox.add_child(ans_label)

	var ans_hbox := HBoxContainer.new()
	ans_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(ans_hbox)

	var cols: Array = data.get("columns", [])
	var cards: Array = data.get("cards", [])
	var types := String(data.get("type", ""))
	var puzzle_type := types

	_feedback_node = Label.new()
	_feedback_node.text = "Pilih jawaban."
	_feedback_node.add_theme_font_size_override("font_size", 10)
	_feedback_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feedback_node.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(_feedback_node)

	if puzzle_type == "column_match":
		_card_total = cards.size()
		_placed_count = 0
		_wrong_count = 0
		var cols_: Array = cols
		var cards_: Array = cards
		var feedback_node: Label = _feedback_node

		for c in cols_:
			var col_vbox := VBoxContainer.new()
			col_vbox.add_theme_constant_override("separation", 4)
			ans_hbox.add_child(col_vbox)
			var col_label := Label.new()
			col_label.text = "[%s]" % c
			col_label.add_theme_font_size_override("font_size", 12)
			col_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.85))
			col_label.custom_minimum_size = Vector2(150, 24)
			col_vbox.add_child(col_label)
			var slot := DropSlot.new()
			slot.column = String(c)
			slot.pressed.connect(func():
				feedback_node.text = "Seret kartu nilai ke slot ini."
			)
			slot.value_dropped.connect(func(payload: Dictionary):
				var val := String(payload.get("value", ""))
				var cname := String(payload.get("column", ""))
				if cname != String(c):
					feedback_node.text = "Salah: '%s' bukan domain kolom %s." % [val, c]
					_wrong_count += 1
					return
				if _filled.has(c):
					feedback_node.text = "Kolom %s sudah terisi." % c
					return
				slot.mark_filled(val, true)
				_filled[c] = true
				_placed_count += 1
				feedback_node.text = "Benar: %s masuk domain kolom %s." % [val, c]
				if _placed_count >= cols_.size():
					_finish(column_type_ok())
			)
			col_vbox.add_child(slot)
			_slots[c] = slot

		var val_label := Label.new()
		val_label.text = "Nilai tersedia:"
		val_label.add_theme_font_size_override("font_size", 12)
		val_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
		vbox.add_child(val_label)

		var val_hbox := HBoxContainer.new()
		val_hbox.add_theme_constant_override("separation", 6)
		vbox.add_child(val_hbox)

		for cd in cards_:
			var val := String(cd.get("value", ""))
			var col := String(cd.get("column", ""))
			var card := DragValueCard.new()
			card.text = val
			card.payload = {"type": "value", "value": val, "column": col}
			card.add_theme_color_override("font_color", Color(0.9, 0.93, 0.96))
			card.add_theme_font_size_override("font_size", 11)
			card.custom_minimum_size = Vector2(110, 28)
			card.pressed.connect(func():
				feedback_node.text = "Dipilih: %s (pilih slot kolom yang benar)." % val
			)
			val_hbox.add_child(card)

	elif puzzle_type == "fk_fix":
		var feedback_node: Label = _feedback_node
		var col_vbox := VBoxContainer.new()
		col_vbox.add_theme_constant_override("separation", 4)
		ans_hbox.add_child(col_vbox)
		var col_label := Label.new()
		col_label.text = "Kolom FK"
		col_label.add_theme_font_size_override("font_size", 12)
		col_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.85))
		col_vbox.add_child(col_label)
		var slot := DropSlot.new()
		slot.column = String(data.get("columns", [])[0] if data.get("columns", []).size() > 0 else "id_dosen")
		var target := String(data.get("table", "")) + "." + slot.column
		slot.value_dropped.connect(func(payload: Dictionary):
			var val := String(payload.get("value", ""))
			if not _fk_valid(val):
				feedback_node.text = "FK tidak valid: '%s'." % val
				return
			slot.mark_filled(val, true)
			feedback_node.text = "FK diperbaiki: %s = %s" % [target, val]
			for a in get_tree().get_nodes_in_group("fk_anchor"):
				if a.has_method("set_fk_value"):
					a.set_fk_value(val)
			for e in get_tree().get_nodes_in_group("orphan_glitch"):
				if is_instance_valid(e):
					e.queue_free()
			var stars := 3 if val != "NULL" else 2
			GameState.solve_puzzle(String(data["id"]), stars, 80)
			GameState.refresh_rank()
			get_tree().create_timer(1.4, true).timeout.connect(_close)
			AudioManager.play_sfx("puzzle_correct")
		)
		col_vbox.add_child(slot)
		var vl := Label.new()
		vl.text = "Nilai tersedia:"
		vl.add_theme_font_size_override("font_size", 12)
		vl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92))
		vbox.add_child(vl)
		var vh := HBoxContainer.new()
		vh.add_theme_constant_override("separation", 6)
		vbox.add_child(vh)
		var opts: Array = data.get("valid_values", [])
		if data.get("allow_null", false):
			opts.append("NULL")
		for ov in opts:
			var card := DragValueCard.new()
			card.text = String(ov)
			card.payload = {"type": "value", "value": String(ov), "column": slot.column}
			card.add_theme_color_override("font_color", Color(0.9, 0.93, 0.96))
			card.add_theme_font_size_override("font_size", 11)
			card.custom_minimum_size = Vector2(110, 28)
			card.pressed.connect(func():
				feedback_node.text = "Pilih: %s" % String(ov)
			)
			vh.add_child(card)

	# ---- kartu penjelasan ----
	var expl_panel := PanelContainer.new()
	var sbx := StyleBoxFlat.new()
	sbx.bg_color = Color(0.07, 0.09, 0.12)
	sbx.set_border_width_all(2)
	sbx.border_color = Color(0.2, 0.25, 0.3)
	sbx.corner_radius_top_left = 6
	sbx.corner_radius_top_right = 6
	sbx.corner_radius_bottom_left = 6
	sbx.corner_radius_bottom_right = 6
	expl_panel.add_theme_stylebox_override("panel", sbx)
	expl_panel.custom_minimum_size = Vector2(720, 100)
	vbox.add_child(expl_panel)
	var ev := VBoxContainer.new()
	expl_panel.add_child(ev)
	var ex_title := Label.new()
	ex_title.text = "Penjelasan Materi"
	ex_title.add_theme_font_size_override("font_size", 12)
	ex_title.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	ev.add_child(ex_title)
	var explanations: Dictionary = data.get("explanations", {})
	var expl_parts: Array = []
	for c in cols:
		if explanations.has(c):
			expl_parts.append("%s: %s" % [c, explanations[c]])
	if expl_parts.size() == 0:
		if explanations.has("valid"):
			expl_parts.append(String(explanations["valid"]))
		if explanations.has("null"):
			expl_parts.append("NULL: %s" % String(explanations["null"]))
		if explanations.has("invalid"):
			expl_parts.append("Salah: %s" % String(explanations["invalid"]))
	var expl_lbl := Label.new()
	expl_lbl.text = "  ".join(PackedStringArray(expl_parts))
	expl_lbl.add_theme_font_size_override("font_size", 10)
	expl_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	expl_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.9))
	ev.add_child(expl_lbl)

	# ---- tombol tutup ----
	var close_btn := Button.new()
	close_btn.text = "Tutup (Esc)"
	close_btn.add_theme_font_size_override("font_size", 11)
	close_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	var sbcb := StyleBoxFlat.new()
	sbcb.bg_color = Color(0.3, 0.3, 0.35)
	sbcb.corner_radius_top_left = 5
	sbcb.corner_radius_top_right = 5
	sbcb.corner_radius_bottom_left = 5
	sbcb.corner_radius_bottom_right = 5
	close_btn.add_theme_stylebox_override("normal", sbcb)
	close_btn.add_theme_stylebox_override("hover", sbcb)
	close_btn.add_theme_stylebox_override("pressed", sbcb)
	close_btn.pressed.connect(func(): _close())
	vbox.add_child(close_btn)

func _fk_valid(value: String) -> bool:
	var valid: Array = data.get("valid_values", [])
	for v in valid:
		if String(v) == value or (value == "NULL" and v == null):
			return true
	return false

func column_type_ok() -> bool:
	# all columns filled
	for c in data.get("columns", []):
		if not _filled.has(c):
			return false
	return true

func _finish(ok: bool) -> void:
	var feedback: Label = _feedback_node
	var wrong := _wrong_count
	var stars := 3 if wrong == 0 else (2 if wrong <= 2 else 1)
	GameState.solve_puzzle(String(data["id"]), stars, 80)
	GameState.refresh_rank()
	feedback.text = "Selesai! Tabel %s utuh. Bintang: %d" % [String(data.get("table", "")), stars]
	AudioManager.play_sfx("puzzle_correct")
	get_tree().create_timer(1.4, true).timeout.connect(_close)

func _close() -> void:
	if _open_ui != null:
		_open_ui.queue_free()
		_open_ui = null
	process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().paused = false
