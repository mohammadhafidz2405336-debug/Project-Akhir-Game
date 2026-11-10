extends Node
## GameState - state pemain & progres (GDD 3.1). Satu sumber kebenaran.

const XP_THRESHOLDS := [0, 100, 250, 450, 700, 1000, 1350, 1750, 2200, 2700]
const RANKS := ["Novice", "Apprentice", "Analyst", "Architect", "Grandmaster"]
const TOTAL_PUZZLES := 9

var health_max := 5
var health := 5
var energy_max := 50.0
var energy := 50.0
var logic_xp := 0
var logic_level := 1
var fragments := 0
var memory_crystals := 0
var logic_cores := 0
var ancient_records: Array = []
var schema_keys: Array = []
var collected_ids: Dictionary = {}   # id -> true
var solved_puzzles: Dictionary = {}  # id -> bintang terbaik (1..3)
var levels_completed: Dictionary = {}  # "L1" -> true
var difficulty := "standard"
var run_time := 0.0
var last_sync := {"level": "L1", "x": 0.0, "y": 0.0}
var health_tier := 0
var energy_tier := 0
var damage_tier := 0
var hints_left := 0

## ---------- reset / sesi ----------
func reset_run() -> void:
	health_max = 5
	health = 5
	energy_max = 50.0
	energy = 50.0
	logic_xp = 0
	logic_level = 1
	fragments = 0
	memory_crystals = 0
	logic_cores = 0
	ancient_records = []
	schema_keys = []
	collected_ids = {}
	solved_puzzles = {}
	levels_completed = {}
	run_time = 0.0
	health_tier = 0
	energy_tier = 0
	damage_tier = 0
	hints_left = 0
	last_sync = {"level": "L1", "x": 0.0, "y": 0.0}
	SkillManager.reset_skills()

func difficulty_damage_mult() -> float:
	match difficulty:
		"guided": return 0.5
		"challenge": return 1.5
	return 1.0

func difficulty_regen_mult() -> float:
	match difficulty:
		"guided": return 1.5
		"challenge": return 0.75
	return 1.0

## ---------- health / energy ----------
func set_health(v: int) -> void:
	var old := health
	health = clampi(v, 0, health_max)
	if old != health:
		EventBus.health_changed.emit(old, health)
	if health <= 0:
		EventBus.player_died.emit()

func heal(v: int) -> void:
	set_health(health + v)

func damage(v: int) -> void:
	var amount := int(ceil(v * difficulty_damage_mult()))
	set_health(health - maxi(1, amount))

func add_health_max(v: int) -> void:
	var old := health_max
	health_max += v
	EventBus.health_max_changed.emit(health_max)
	health = health_max
	EventBus.health_changed.emit(old, health)

func set_energy(v: float) -> void:
	var old := energy
	energy = clampf(v, 0.0, energy_max)
	if absf(old - energy) > 0.01:
		EventBus.energy_changed.emit(old, energy)

func add_energy(v: float) -> void:
	set_energy(energy + v)

func spend_energy(v: float) -> bool:
	if energy + 0.001 < v:
		return false
	set_energy(energy - v)
	return true

func add_energy_max(v: float) -> void:
	var old := energy_max
	energy_max += v
	EventBus.energy_max_changed.emit(energy_max)
	set_energy(energy_max)

## ---------- ekonomi & XP ----------
func add_fragments(v: int) -> void:
	var old := fragments
	fragments = maxi(0, fragments + v)
	EventBus.fragments_changed.emit(old, fragments)

func spend_fragments(v: int) -> bool:
	if fragments < v:
		return false
	add_fragments(-v)
	return true

func add_material(kind: String, amount: int = 1) -> void:
	match kind:
		"memory_crystal":
			memory_crystals = mini(99, memory_crystals + amount)
		"logic_core":
			logic_cores = mini(10, logic_cores + amount)

func add_schema_key(key_id: String) -> void:
	if not schema_keys.has(key_id):
		schema_keys.append(key_id)

func add_ancient_record(id: String) -> void:
	if not ancient_records.has(id):
		ancient_records.append(id)
		add_xp(25)

func add_xp(v: int) -> void:
	if v <= 0:
		return
	logic_xp += v
	var new_level := logic_level
	for i in range(XP_THRESHOLDS.size()):
		if logic_xp >= XP_THRESHOLDS[i]:
			new_level = i + 1
	if new_level > logic_level:
		logic_level = new_level
		add_fragments(10 * logic_level)
		if logic_level == 4 or logic_level == 7:
			add_energy_max(10.0)
		EventBus.logic_level_up.emit(logic_level)
	EventBus.logic_xp_changed.emit(logic_xp, logic_level)

func xp_for_next_level() -> int:
	if logic_level >= XP_THRESHOLDS.size():
		return XP_THRESHOLDS[-1]
	return XP_THRESHOLDS[logic_level]

## ---------- puzzle & rank ----------
func puzzle_stars(id: String) -> int:
	return int(solved_puzzles.get(id, 0))

func solve_puzzle(id: String, stars: int, xp: int) -> void:
	var best := maxi(puzzle_stars(id), stars)
	var first := not solved_puzzles.has(id)
	solved_puzzles[id] = best
	EventBus.puzzle_solved.emit(id, best)
	if first:
		add_xp(xp)

func mastery_percent() -> int:
	if solved_puzzles.is_empty():
		return 0
	var total := 0
	for k in solved_puzzles:
		total += int(solved_puzzles[k])
	return int(round(100.0 * total / float(TOTAL_PUZZLES * 3)))

func rank() -> String:
	var m := mastery_percent()
	if m >= 90: return RANKS[4]
	if m >= 75: return RANKS[3]
	if m >= 50: return RANKS[2]
	if m >= 25: return RANKS[1]
	return RANKS[0]

func refresh_rank() -> void:
	EventBus.rank_changed.emit(rank())

## ---------- collectible ----------
func has_collected(id: String) -> bool:
	return collected_ids.has(id)

func collect(id: String, type: String) -> bool:
	if id != "" and has_collected(id):
		return false
	if id != "":
		collected_ids[id] = true
	EventBus.collectible_taken.emit(id, type)
	return true

## ---------- level ----------
func complete_level(level_id: String) -> void:
	if levels_completed.has(level_id):
		return
	levels_completed[level_id] = true
	EventBus.level_completed.emit(level_id)

func is_level_unlocked(level_id: String) -> bool:
	match level_id:
		"L1": return true
		"L2": return levels_completed.has("L1")
		"L3": return levels_completed.has("L2")
	return false

## ---------- persistensi ----------
func to_dict() -> Dictionary:
	return {
		"health_max": health_max, "health": health, "energy_max": energy_max,
		"energy": energy, "logic_xp": logic_xp, "logic_level": logic_level,
		"fragments": fragments, "memory_crystals": memory_crystals,
		"logic_cores": logic_cores, "ancient_records": ancient_records,
		"schema_keys": schema_keys, "collected_ids": collected_ids,
		"solved_puzzles": solved_puzzles, "levels_completed": levels_completed,
		"difficulty": difficulty, "run_time": run_time, "last_sync": last_sync,
		"health_tier": health_tier, "energy_tier": energy_tier,
		"damage_tier": damage_tier, "hints_left": hints_left,
	}

func from_dict(d: Dictionary) -> void:
	health_max = int(d.get("health_max", 5))
	health = clampi(int(d.get("health", health_max)), 1, health_max)
	energy_max = float(d.get("energy_max", 50.0))
	energy = float(d.get("energy", energy_max))
	logic_xp = int(d.get("logic_xp", 0))
	logic_level = int(d.get("logic_level", 1))
	fragments = int(d.get("fragments", 0))
	memory_crystals = int(d.get("memory_crystals", 0))
	logic_cores = int(d.get("logic_cores", 0))
	ancient_records = d.get("ancient_records", [])
	schema_keys = d.get("schema_keys", [])
	collected_ids = d.get("collected_ids", {})
	solved_puzzles = d.get("solved_puzzles", {})
	levels_completed = d.get("levels_completed", {})
	difficulty = String(d.get("difficulty", "standard"))
	run_time = float(d.get("run_time", 0.0))
	last_sync = d.get("last_sync", last_sync)
	health_tier = int(d.get("health_tier", 0))
	energy_tier = int(d.get("energy_tier", 0))
	damage_tier = int(d.get("damage_tier", 0))
	hints_left = int(d.get("hints_left", 0))

func _process(delta: float) -> void:
	if not get_tree().paused:
		run_time += delta
