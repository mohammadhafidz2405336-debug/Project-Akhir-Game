extends Node
## SaveManager - simpan/muat status ke user://save.json (GDD 1.3).

const PATH := "user://save.json"

func has_save() -> bool:
	return FileAccess.file_exists(PATH)

func save_game() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: gagal menulis %s" % PATH)
		return
	f.store_string(JSON.stringify(GameState.to_dict(), "\t"))

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	GameState.from_dict(parsed)
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))