extends Node
## RoomManager - transisi level, sync point, respawn, batas kamera (GDD 2.2 catatan).

const LEVELS := {
	"L1": {"scene": "res://scenes/levels/level1_record_ruins.tscn", "nama": "Record Ruins"},
	"L2": {"scene": "res://scenes/levels/level2_key_citadel.tscn", "nama": "Key Citadel"},
	"L3": {"scene": "res://scenes/levels/level3_foreign_spire.tscn", "nama": "Foreign Spire"},
}

var current_level := ""
var current_room := ""
var last_checkpoint := Vector2.ZERO
var level_scene: Node = null
## true bila level dimuat lewat tombol LANJUTKAN (posisi dari save dipakai)
var resume_from_save := false

func load_level(id: String) -> void:
	if not LEVELS.has(id):
		push_error("RoomManager: level tidak dikenal %s" % id)
		return
	current_level = id
	EventBus.health_changed.emit(0, GameState.health)
	get_tree().change_scene_to_file(LEVELS[id]["scene"])

func level_name(id: String) -> String:
	return String(LEVELS.get(id, {}).get("nama", id))

func goto_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func goto_level_select() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func goto_end_session(win: bool) -> void:
	GameState.set_meta("last_win", win)
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/end_session.tscn")

func enter_room(id: String) -> void:
	if current_room == id:
		return
	current_room = id
	EventBus.room_entered.emit(id)

func set_checkpoint(level_id: String, pos: Vector2) -> void:
	last_checkpoint = pos
	GameState.last_sync = {"level": level_id, "x": pos.x, "y": pos.y}

func start_new_run() -> void:
	resume_from_save = false
	GameState.reset_run()
	SaveManager.delete_save()
	load_level("L1")