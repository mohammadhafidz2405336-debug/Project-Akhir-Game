extends Node
## EventBus - pusat sinyal global (GDD 5.2). Tidak menyimpan state.

signal health_changed(old: int, new: int)
signal energy_changed(old: float, new: float)
signal fragments_changed(old: int, new: int)
signal logic_xp_changed(xp: int, level: int)
signal logic_level_up(level: int)
signal rank_changed(rank: String)
signal skill_unlocked(id: String)
signal puzzle_solved(id: String, stars: int)
signal collectible_taken(id: String, type: String)
signal room_entered(id: String)
signal level_completed(level_id: String)
signal player_died()
signal boss_defeated(id: String)
signal market_purchase(item_id: String, tier: int)
## tambahan untuk UI/dialog
signal message(text: String)
signal health_max_changed(value: int)
signal energy_max_changed(value: float)
