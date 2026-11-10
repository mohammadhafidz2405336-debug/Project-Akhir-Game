extends CanvasLayer
## MarketUI - Data Market (GDD 3.4, P1). Harga dari data/market_items.json.

@onready var list: VBoxContainer = $Panel/List
@onready var feedback: Label = $Panel/Feedback
@onready var close_btn: Button = $Panel/Close

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	close_btn.pressed.connect(close)
	_build()

func close() -> void:
	AudioManager.play_sfx("ui_click")
	get_tree().paused = false
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close()

func _build() -> void:
	for c in list.get_children():
		c.queue_free()
	feedback.text = "Fragments: %d   Memory Crystal: %d" % [GameState.fragments, GameState.memory_crystals]
	if MarketManager.items.is_empty():
		feedback.text = "Data Market kosong (data/market_items.json tidak terbaca)."
		return
	for it in MarketManager.items:
		var id := String(it.get("id", ""))
		var price := int(it.get("cost", 0))
		var mc := int(it.get("cost_mc", 0))
		var label := String(it.get("nama", id))
		if mc > 0:
			label += " (+%d MC)" % mc
		var btn := Button.new()
		btn.text = "%s  -  %d FG  [Lv %d]" % [label, price, int(it.get("min_level", 1))]
		btn.custom_minimum_size = Vector2(0, 22)
		btn.add_theme_font_size_override("font_size", 8)
		btn.pressed.connect(_buy.bind(id))
		list.add_child(btn)

func _buy(id: String) -> void:
	var res := MarketManager.buy(id)
	feedback.text = String(res.get("reason", ""))
	AudioManager.play_sfx("purchase" if bool(res.get("ok", false)) else "puzzle_wrong")
	_build()
