extends Node
## MarketManager - Data Market (GDD 3.4). Harga dari data/market_items.json.

const DATA_PATH := "res://data/market_items.json"

var items: Array = []
var owned := {}  # id -> tier yang sudah dibeli

func _ready() -> void:
	var f := FileAccess.open(DATA_PATH, FileAccess.READ)
	if f == null:
		push_warning("MarketManager: %s tidak ditemukan" % DATA_PATH)
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		items = parsed.get("items", [])

func item(id: String) -> Dictionary:
	for it in items:
		if String(it.get("id", "")) == id:
			return it
	return {}

func next_tier(id: String) -> int:
	return int(owned.get(id, 0)) + 1

## Validasi berurutan: tier -> syarat level -> batas bawa -> saldo.
func check(id: String) -> Dictionary:
	var it := item(id)
	if it.is_empty():
		return {"ok": false, "reason": "Item tidak dikenal."}
	var tier := int(it.get("tier", 1))
	var cur := int(owned.get(id, 0))
	if "max_tier" in it and cur >= int(it["max_tier"]):
		return {"ok": false, "reason": "Tier maksimum sudah dibeli."}
	if cur + 1 != tier and "max_tier" in it:
		return {"ok": false, "reason": "Beli tier sebelumnya dahulu."}
	if GameState.logic_level < int(it.get("min_level", 1)):
		return {"ok": false, "reason": "Butuh Logic Level %d." % int(it["min_level"])}
	if int(it.get("cost_mc", 0)) > GameState.memory_crystals:
		return {"ok": false, "reason": "Memory Crystal kurang."}
	if "carry_max" in it and int(owned.get(id + "_carry", 0)) >= int(it["carry_max"]):
		return {"ok": false, "reason": "Batas bawa tercapai."}
	if GameState.fragments < int(it.get("cost", 0)):
		return {"ok": false, "reason": "Data Fragment kurang (%d)." % int(it.get("cost", 0))}
	return {"ok": true, "reason": "", "item": it}

func buy(id: String) -> Dictionary:
	var res := check(id)
	if not bool(res["ok"]):
		AudioManager.play_sfx("puzzle_wrong")
		return res
	var it: Dictionary = res["item"]
	GameState.spend_fragments(int(it.get("cost", 0)))
	GameState.memory_crystals -= int(it.get("cost_mc", 0))
	match String(it.get("effect", "")):
		"health_max":
			GameState.add_health_max(int(it.get("value", 1)))
			GameState.health_tier = int(it.get("tier", 1))
		"energy_max":
			GameState.add_energy_max(float(it.get("value", 20)))
			GameState.energy_tier = int(it.get("tier", 1))
		"damage":
			GameState.damage_tier = int(it.get("tier", 1))
		"energy":
			GameState.add_energy(float(it.get("value", 50)))
		"heal":
			GameState.heal(int(it.get("value", 2)))
		"hint":
			GameState.hints_left += 1
	if "carry_max" in it:
		owned[id + "_carry"] = int(owned.get(id + "_carry", 0)) + 1
	if "max_tier" in it:
		owned[id] = int(it.get("tier", 1))
	AudioManager.play_sfx("purchase")
	EventBus.market_purchase.emit(id, int(it.get("tier", 1)))
	SaveManager.save_game()
	return {"ok": true, "reason": "Berhasil membeli %s." % String(it.get("nama", id))}

func damage_bonus() -> int:
	return GameState.damage_tier