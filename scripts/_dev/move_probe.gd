extends Node
## Probe: apakah gerak ke kanan tersendat? Ukur delta x per frame & progres frame animasi.

func _ready() -> void:
	await get_tree().process_frame
	get_tree().current_scene.get_node("Box/Play").pressed.emit()
	await get_tree().create_timer(1.2).timeout
	var p: CharacterBody2D = get_tree().get_first_node_in_group("player")
	await get_tree().create_timer(0.3).timeout

	Input.action_press("move_right")
	var last_x: float = p.global_position.x
	var deltas: Array = []
	var frames: Array = []
	var anims: Array = []
	for i in 40:
		await get_tree().physics_frame
		var dx: float = p.global_position.x - last_x
		last_x = p.global_position.x
		deltas.append(snappedf(dx, 0.01))
		frames.append(p.sprite.frame)
		anims.append(String(p.sprite.animation))
	Input.action_release("move_right")
	print("PROBE anim: ", anims[0], " -> ", anims[-1])
	print("PROBE frame: ", frames)
	print("PROBE dx: ", deltas)
	var zero := 0
	for d in deltas:
		if d < 0.5:
			zero += 1
	print("PROBE frame dx ~0 (berhenti): ", zero, "/", deltas.size())
	get_tree().quit(0)