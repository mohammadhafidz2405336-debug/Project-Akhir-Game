extends Area2D
## Pickup - collectible (GDD 3.2). Diambil otomatis saat pemain menyentuh.

const TEX := {
	"fragment": "res://assets/sprites/items/fragment.png",
	"memory_crystal": "res://assets/sprites/items/memory_crystal.png",
	"logic_core": "res://assets/sprites/items/logic_core.png",
	"schema_key": "res://assets/sprites/items/schema_key.png",
	"ancient_record": "res://assets/sprites/items/ancient_record.png",
	"energy_cell": "res://assets/sprites/items/energy_cell.png",
}

@export_enum("fragment", "memory_crystal", "logic_core", "schema_key", "ancient_record", "energy_cell")
var kind := "fragment"
@export var collectible_id := ""
@export var amount := 1

var _taken := false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("pickup")
	body_entered.connect(_on_body_entered)
	if collectible_id != "" and GameState.has_collected(collectible_id):
		queue_free()
		return
	sprite.texture = load(TEX.get(kind, TEX["fragment"]))
	var t := create_tween().set_loops()
	t.tween_property(sprite, "position:y", -3.0, 0.7).set_trans(Tween.TRANS_SINE)
	t.tween_property(sprite, "position:y", 0.0, 0.7).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if _taken or not body.is_in_group("player"):
		return
	_taken = true
	_apply()
	AudioManager.play_sfx("pickup")
	EventBus.collectible_taken.emit(collectible_id, kind)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "global_position:y", global_position.y - 14, 0.25)
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.25)
	await t.finished
	queue_free()

func _apply() -> void:
	match kind:
		"fragment":
			GameState.add_fragments(amount)
		"memory_crystal":
			GameState.add_material("memory_crystal", amount)
			GameState.collect(collectible_id, kind)
		"logic_core":
			GameState.add_material("logic_core", amount)
			GameState.collect(collectible_id, kind)
		"energy_cell":
			GameState.add_energy(15.0)
			GameState.collect(collectible_id, kind)
		"schema_key":
			GameState.add_schema_key(collectible_id if collectible_id != "" else "key")
			GameState.collect(collectible_id, kind)
			EventBus.message.emit("Schema Key diperoleh. Schema Gate terbuka.")
		"ancient_record":
			GameState.collect(collectible_id, kind)
			GameState.add_ancient_record(collectible_id)
			_show_record()
	GameState.add_xp(1 if kind == "fragment" else 0)

func _show_record() -> void:
	var text := ""
	var f := FileAccess.open("res://data/glossary.json", FileAccess.READ)
	if f != null:
		var parsed = JSON.parse_string(f.get_as_text())
		for r in parsed.get("records", []):
			if String(r.get("id", "")) == collectible_id:
				text = "%s\n\n%s" % [String(r.get("judul", "")), String(r.get("isi", ""))]
	if text == "":
		text = "Ancient Record %s tersimpan di Journal." % collectible_id
	EventBus.message.emit("ANCIENT RECORD: " + text)
