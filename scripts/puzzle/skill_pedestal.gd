extends Area2D
## SkillPedestal - membuka skill sekali saat pemain menekan E (GDD 5.3).

@export_enum("scan", "strike", "bridge") var skill := "scan"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _used := false

func _ready() -> void:
	sprite.texture = load("res://assets/sprites/ui/pedestal.png")
	label.text = "Tekan E"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if SkillManager.is_unlocked(skill):
		_used = true
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _used:
		body.interacting = self
		label.visible = true
		label.text = "Ambil %s (E)" % String(SkillManager.DEFS[skill]["nama"])

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.interacting == self:
		body.interacting = null
		label.visible = false

func interact(player: Node) -> void:
	if _used:
		return
	_used = true
	SkillManager.unlock(skill)
	player.interacting = null
	AudioManager.play_sfx("puzzle_correct")
	label.visible = false
	var texts := {
		"scan": "Data Scan diperoleh! Tekan 1 untuk memindai objek di radius 96 px. Objek tersembunyi akan terlihat 8 detik.",
		"strike": "Unique Strike diperoleh! Tekan 3 untuk menerjang 80 px. Tembok kristal hanya pecah oleh kolom yang tepat.",
		"bridge": "Relation Bridge diperoleh! Tekan 5 di FK Anchor, lalu 5 di PK Anchor. Jembatan bertahan 20 detik.",
	}
	EventBus.message.emit(texts.get(skill, "Skill diperoleh."))
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	await t.finished
	queue_free()