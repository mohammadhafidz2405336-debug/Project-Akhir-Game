extends CanvasLayer
## PauseMenu - dipanggil level_base lewat tombol Esc/P.

@onready var resume_btn: Button = $Panel/Box/Resume
@onready var menu_btn: Button = $Panel/Box/Menu

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(toggle)
	menu_btn.pressed.connect(_goto_menu)

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	AudioManager.play_sfx("ui_click")

func _goto_menu() -> void:
	get_tree().paused = false
	RoomManager.goto_menu()