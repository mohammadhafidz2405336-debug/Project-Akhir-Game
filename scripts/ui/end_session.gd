extends Control
## EndSession - layar Menang/Kalah dengan statistik (GDD 2.2 W2-10).

@onready var title: Label = $Title
@onready var stats: Label = $Stats
@onready var retry_btn: Button = $Box/Retry
@onready var menu_btn: Button = $Box/Menu

func _ready() -> void:
	get_tree().paused = false
	var win := bool(GameState.get_meta("last_win", false))
	AudioManager.play_music("menu")
	title.text = "ANDA MENANG - SCHEMA DIPULIHKAN" if win else "SESSION SELESAI - KALAH"
	title.add_theme_color_override("font_color",
		Color(0.6, 1, 0.75) if win else Color(1, 0.55, 0.55))
	var secs := int(GameState.run_time)
	stats.text = "Waktu: %d:%02d\nData Fragments: %d\nLogic Level: %d (XP %d)\nKnowledge Rank: %s\nAncient Record: %d\nPuzzle selesai: %d/%d" % [
		secs / 60, secs % 60, GameState.fragments, GameState.logic_level, GameState.logic_xp,
		GameState.rank(), GameState.ancient_records.size(),
		GameState.solved_puzzles.size(), GameState.TOTAL_PUZZLES]
	retry_btn.pressed.connect(_on_retry)
	menu_btn.pressed.connect(_on_menu)

func _on_retry() -> void:
	AudioManager.play_sfx("ui_click")
	RoomManager.load_level(String(GameState.last_sync.get("level", "L1")))

func _on_menu() -> void:
	AudioManager.play_sfx("ui_click")
	RoomManager.goto_menu()
