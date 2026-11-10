extends Node
## Shots - menyimpan tangkapan layar nyata ke docs/progress/week2/ sebagai bukti
## (GDD 7.4). Jalankan dengan display: xvfb-run godot --path . -- --shots

const OUT := "res://docs/progress/week2/"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await get_tree().process_frame
	await _shot("01_menu")
	RoomManager.start_new_run()
	await _wait(60)
	await _shot("02_level1_start")
	var p: Node2D = get_tree().get_first_node_in_group("player")
	if p != null:
		p.global_position += Vector2(240, -40)
		await _wait(30)
		await _shot("03_level1_ruins")
	RoomManager.load_level("L2")
	await _wait(60)
	await _shot("04_level2_citadel")
	RoomManager.load_level("L3")
	await _wait(60)
	await _shot("05_level3_spire")
	RoomManager.goto_level_select()
	await _wait(30)
	await _shot("06_level_select")
	RoomManager.goto_end_session(true)
	await _wait(30)
	await _shot("07_end_session")
	print("SHOTS selesai")
	get_tree().quit()

func _wait(frames: int) -> void:
	for i in frames:
		await get_tree().process_frame

func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var path := OUT + name + ".png"
	var err := img.save_png(ProjectSettings.globalize_path(path))
	print("SHOT ", path, " err=", err, " size=", img.get_size())
