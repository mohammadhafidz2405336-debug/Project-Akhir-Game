extends Node
## SkillManager - status skill, biaya energy, cooldown (GDD 3.3).

const DEFS := {
	"scan": {"nama": "Data Scan", "key": "1", "cost": 10.0, "cd": 1.0},
	"strike": {"nama": "Unique Strike", "key": "3", "cost": 20.0, "cd": 2.0},
	"bridge": {"nama": "Relation Bridge", "key": "5", "cost": 25.0, "cd": 0.5},
}

var unlocked := {"scan": false, "strike": false, "bridge": false}
var _cd := {}

func reset_skills() -> void:
	for k in unlocked:
		unlocked[k] = false
	_cd.clear()

func unlock(id: String) -> bool:
	if not unlocked.has(id) or unlocked[id]:
		return false
	unlocked[id] = true
	EventBus.skill_unlocked.emit(id)
	return true

func is_unlocked(id: String) -> bool:
	return bool(unlocked.get(id, false))

func cooldown_left(id: String) -> float:
	return maxf(0.0, float(_cd.get(id, 0.0)))

func can_use(id: String) -> bool:
	if not is_unlocked(id):
		return false
	if cooldown_left(id) > 0.0:
		return false
	return GameState.energy + 0.001 >= float(DEFS[id]["cost"])

## Biaya energy dipotong di sini; efek dijalankan oleh pemanggil.
func pay(id: String) -> bool:
	if not can_use(id):
		return false
	GameState.spend_energy(float(DEFS[id]["cost"]))
	_cd[id] = float(DEFS[id]["cd"])
	AudioManager.play_sfx("skill")
	return true

func _process(delta: float) -> void:
	for k in _cd.keys():
		if _cd[k] > 0.0:
			_cd[k] = maxf(0.0, _cd[k] - delta)