extends Control
## MainMenu - Start Screen (GDD 2.2 W2-10). Menjalankan autotest bila dipanggil
## dengan `-- --autotest` (bukti uji otomatis, lihat scripts/_dev/autotest.gd).

@onready var play_btn: Button = $Box/Play
@onready var cont_btn: Button = $Box/Continue
@onready var select_btn: Button = $Box/LevelSelect
@onready var about_btn: Button = $Box/About
@onready var quit_btn: Button = $Box/Quit

func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music("menu")
	play_btn.pressed.connect(_on_play)
	cont_btn.pressed.connect(_on_continue)
	select_btn.pressed.connect(_go.bind(RoomManager.goto_level_select))
	about_btn.pressed.connect(_go.bind(func(): get_tree().change_scene_to_file("res://scenes/ui/about.tscn")))
	quit_btn.pressed.connect(func(): get_tree().quit())
	cont_btn.disabled = not SaveManager.has_save()
	cont_btn.tooltip_text = "Tidak ada progres tersimpan" if cont_btn.disabled else "Lanjutkan dari checkpoint terakhir"
	play_btn.grab_focus()
	var args := OS.get_cmdline_user_args()
	if "--autotest" in args:
		var t: Node = load("res://scripts/_dev/autotest.gd").new()
		t.name = "Autotest"
		get_tree().root.add_child.call_deferred(t)
	elif "--shots" in args:
		var s: Node = load("res://scripts/_dev/shots.gd").new()
		s.name = "Shots"
		get_tree().root.add_child.call_deferred(s)
	elif "--menuprobe" in args and not get_tree().root.has_node("MenuProbe"):
		var p: Node = load("res://scripts/_dev/menu_probe.gd").new()
		p.name = "MenuProbe"
		get_tree().root.add_child.call_deferred(p)

func _go(f: Callable) -> void:
	AudioManager.play_sfx("ui_click")
	f.call()

func _on_play() -> void:
	AudioManager.play_sfx("ui_click")
	RoomManager.start_new_run()

func _on_continue() -> void:
	AudioManager.play_sfx("ui_click")
	if not SaveManager.load_game():
		return
	RoomManager.resume_from_save = true
	RoomManager.load_level(String(GameState.last_sync.get("level", "L1")))
