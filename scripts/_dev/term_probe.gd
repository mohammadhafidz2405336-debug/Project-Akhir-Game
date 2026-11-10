extends Node
## Probe: (A) E kedua kali tetap membuka puzzle, (B) Esc/E menutup puzzle.

func _ready() -> void:
	await get_tree().process_frame
	get_tree().current_scene.get_node("Box/Play").pressed.emit()
	await get_tree().create_timer(1.2).timeout
	var player := get_tree().get_first_node_in_group("player")
	var term: Node = null
	for n in get_tree().current_scene.find_children("*", "Area2D", true, false):
		if n.get_script() != null and "puzzle_terminal" in String(n.get_script().resource_path):
			term = n
			break
	player.global_position = term.global_position + Vector2(-12, 0)
	await get_tree().create_timer(0.4).timeout
	print("PROBE A interacting=", player.interacting != null)

	for i in 3:
		Input.action_press("interact")
		await get_tree().create_timer(0.15).timeout
		Input.action_release("interact")
		await get_tree().create_timer(0.5).timeout
		var buka := term._open_ui != null
		var slots: Array = term.find_children("*", "Button", true, false).filter(
			func(b): return b.get_script() != null and "drop_slot" in String(b.get_script().resource_path))
		print("PROBE B tekan E ke-%d: ui_terbuka=%s slot=%d paused=%s" % [i + 1, buka, slots.size(), get_tree().paused])
		if buka:
			var esc := InputEventAction.new()
			esc.action = "ui_cancel"
			esc.pressed = true
			Input.parse_input_event(esc)
			await get_tree().create_timer(0.4).timeout
			print("PROBE C setelah Esc: ui=%s paused=%s" % [term._open_ui != null, get_tree().paused])
			Input.action_release("interact")
	get_tree().quit(0)