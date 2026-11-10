extends Control
## LevelSelect - tiga region; L2 terbuka setelah L1 selesai, dst. (GDD 2.2 W2-10).

const ORDER := ["L1", "L2", "L3"]

@onready var buttons: Dictionary = {"L1": $Box/L1, "L2": $Box/L2, "L3": $Box/L3}
@onready var market_btn: Button = $Box/Market
@onready var back_btn: Button = $Box/Back
@onready var status: Label = $Status

func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music("menu")
	for i in ORDER.size():
		var id: String = ORDER[i]
		var btn: Button = buttons[id]
		btn.pressed.connect(_on_level.bind(id))
		btn.disabled = not _unlocked(i)
		btn.text = "%s %s%s" % [id, RoomManager.level_name(id).to_upper(),
			"  (selesai)" if GameState.levels_completed.has(id) else ("" if _unlocked(i) else "  (terkunci)")]
	market_btn.pressed.connect(_open_market)
	back_btn.pressed.connect(func():
		AudioManager.play_sfx("ui_click")
		RoomManager.goto_menu())
	status.text = "Fragments %d  //  Logic Lv %d  //  Solved %d/%d  //  Rank %s" % [
		GameState.fragments, GameState.logic_level,
		GameState.solved_puzzles.size(), GameState.TOTAL_PUZZLES, GameState.rank()]

func _unlocked(index: int) -> bool:
	if index == 0:
		return true
	return GameState.levels_completed.has(ORDER[index - 1])

func _on_level(id: String) -> void:
	AudioManager.play_sfx("ui_click")
	RoomManager.load_level(id)

func _open_market() -> void:
	AudioManager.play_sfx("ui_click")
	var m := preload("res://scenes/ui/market_ui.tscn").instantiate()
	add_child(m)
