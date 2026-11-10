extends CanvasLayer
## HUD - hati, Energy, Logic XP/Level, Data Fragments, 5 slot skill, Knowledge Rank.
## Semua nilai datang dari EventBus (tanpa polling).

const SKILL_ICON := {
	"scan": "res://assets/sprites/ui/skill_scan.png",
	"strike": "res://assets/sprites/ui/skill_strike.png",
	"bridge": "res://assets/sprites/ui/skill_bridge.png",
}
const SLOT_ORDER := ["scan", "vision", "strike", "pulse", "bridge"]

@onready var hearts: HBoxContainer = $Root/Top/Hearts
@onready var energy_bar: ProgressBar = $Root/Top/Bars/EnergyBar
@onready var xp_bar: ProgressBar = $Root/Top/Bars/XPBar
@onready var level_label: Label = $Root/Top/Bars/LevelLabel
@onready var frag_label: Label = $Root/Top/Fragments/FragLabel
@onready var rank_label: Label = $Root/Top/Rank
@onready var message_label: Label = $Root/Message
@onready var slots: HBoxContainer = $Root/Slots
@onready var key_label: Label = $Root/Top/Keys

var _msg_queue: Array = []
var _msg_timer := 0.0

func _ready() -> void:
	EventBus.health_changed.connect(_on_health)
	EventBus.health_max_changed.connect(func(_v): _rebuild_hearts())
	EventBus.energy_changed.connect(_on_energy)
	EventBus.energy_max_changed.connect(func(_v): _on_energy(0, GameState.energy))
	EventBus.fragments_changed.connect(_on_fragments)
	EventBus.logic_xp_changed.connect(_on_xp)
	EventBus.logic_level_up.connect(_on_level_up)
	EventBus.rank_changed.connect(func(r): rank_label.text = "RANK: " + r)
	EventBus.skill_unlocked.connect(_on_skill_unlocked)
	EventBus.message.connect(_push_message)
	EventBus.collectible_taken.connect(_on_collect)
	_rebuild_hearts()
	_on_energy(0, GameState.energy)
	_on_xp(GameState.logic_xp, GameState.logic_level)
	_on_fragments(0, GameState.fragments)
	rank_label.text = "RANK: " + GameState.rank()
	_build_slots()

func _rebuild_hearts() -> void:
	for c in hearts.get_children():
		c.queue_free()
	for i in GameState.health_max:
		var t := TextureRect.new()
		t.texture = load("res://assets/sprites/ui/heart_full.png" if i < GameState.health else "res://assets/sprites/ui/heart_empty.png")
		t.custom_minimum_size = Vector2(11, 10)
		t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		hearts.add_child(t)

func _on_health(_old: int, _new: int) -> void:
	var i := 0
	for c in hearts.get_children():
		if c is TextureRect:
			c.texture = load("res://assets/sprites/ui/heart_full.png" if i < GameState.health else "res://assets/sprites/ui/heart_empty.png")
		i += 1

func _on_energy(_old: float, new: float) -> void:
	energy_bar.max_value = GameState.energy_max
	energy_bar.value = new
	energy_bar.tooltip_text = "Energy %d/%d" % [int(new), int(GameState.energy_max)]

func _on_xp(xp: int, level: int) -> void:
	xp_bar.max_value = GameState.xp_for_next_level()
	xp_bar.value = mini(xp, int(xp_bar.max_value))
	level_label.text = "LOGIC Lv %d  XP %d/%d" % [level, xp, int(xp_bar.max_value)]

func _on_level_up(level: int) -> void:
	_push_message("LOGIC LEVEL UP -> %d (bonus 10 x %d Data Fragments)" % [level, level])

func _on_fragments(_old: int, new: int) -> void:
	frag_label.text = "%d" % new

func _on_collect(_id: String, type: String) -> void:
	if type == "schema_key":
		key_label.text = "KEYS: %d" % GameState.schema_keys.size()
	elif type == "ancient_record":
		key_label.text = "KEYS: %d  RECORDS: %d" % [GameState.schema_keys.size(), GameState.ancient_records.size()]

func _build_slots() -> void:
	for c in slots.get_children():
		c.queue_free()
	var i := 0
	for id in SLOT_ORDER:
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(30, 30)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(26, 26)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		icon.texture = load(SKILL_ICON.get(id, "res://assets/sprites/ui/skill_empty.png"))
		icon.modulate = Color(0.3, 0.3, 0.3, 0.6)
		panel.add_child(icon)
		panel.set_meta("icon", icon)
		panel.set_meta("id", id)
		slots.add_child(panel)
		i += 1
	_update_slot_states()

func _on_skill_unlocked(id: String) -> void:
	_update_slot_states()
	_push_message("Skill baru: " + id)

func _update_slot_states() -> void:
	for panel in slots.get_children():
		var id := String(panel.get_meta("id"))
		var icon: TextureRect = panel.get_meta("icon")
		var unlocked := SkillManager.is_unlocked(id)
		icon.modulate = Color(1, 1, 1, 1) if unlocked else Color(0.3, 0.3, 0.3, 0.5)

func _push_message(text: String) -> void:
	if text.strip_edges() == "":
		return
	_msg_queue.append(text)
	if _msg_queue.size() > 3:
		_msg_queue.pop_front()
	message_label.text = "\n".join(_msg_queue)
	_msg_timer = 5.0
	message_label.modulate.a = 1.0

func _process(delta: float) -> void:
	if _msg_timer > 0.0:
		_msg_timer -= delta
		if _msg_timer <= 0.0:
			_msg_queue.clear()
			var t := create_tween()
			t.tween_property(message_label, "modulate:a", 0.0, 0.6)
	# overlay cooldown sederhana
	for panel in slots.get_children():
		var id := String(panel.get_meta("id"))
		var icon: TextureRect = panel.get_meta("icon")
		if SkillManager.is_unlocked(id) and SkillManager.cooldown_left(id) > 0.0:
			icon.modulate = Color(0.6, 0.7, 0.8, 0.8)
		elif SkillManager.is_unlocked(id):
			icon.modulate = Color(1, 1, 1, 1)