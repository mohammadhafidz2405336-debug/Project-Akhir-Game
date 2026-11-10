extends CharacterBody2D
## NullSovereign - boss akhir L3 (GDD 3.5): 2 fase, perisai hanya pecah oleh
## Relation Bridge yang valid di arena.

signal defeated

const HOVER_SPEED := 34.0
const ORB := preload("res://scenes/enemies/null_orb.tscn")

@export var max_hp := 40
@export var damage := 2

var hp := 40
var phase := 1
var shield := true
var _shield_timer := 0.0
var _shoot_timer := 2.5
var _summon_timer := 6.0
var _dir := 1
var _dead := false
var player: Node2D = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar: ProgressBar = $HpBar
@onready var shield_fx: Sprite2D = $ShieldFx
@onready var hurtbox: Area2D = $Hurtbox
@onready var origin: Vector2 = global_position

func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemy")
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	AudioManager.play_music("boss")
	if GameState.solved_puzzles.has("L3_BOSS"):
		shield = false
	EventBus.message.emit("NULL SOVEREIGN muncul! Perisai hanya pecah oleh relasi yang valid.")

func _physics_process(delta: float) -> void:
	if _dead:
		return
	phase = 1 if hp > max_hp * 0.5 else 2
	origin.y += sin(Time.get_ticks_msec() / 900.0) * 6.0 * delta
	velocity = Vector2(_dir * HOVER_SPEED, 0)
	if absf(global_position.x - origin.x) > 90.0:
		_dir *= -1
	move_and_slide()

	if shield:
		_shield_timer -= delta
		shield_fx.visible = true
		shield_fx.modulate.a = 0.5 + 0.3 * sin(Time.get_ticks_msec() / 200.0)
		if _check_bridge():
			_break_shield()
	else:
		_shield_timer -= delta
		shield_fx.visible = false
		if _shield_timer <= 0.0:
			shield = true
			EventBus.message.emit("Perisai Null Sovereign menyala lagi. Buat link baru!")

	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		_shoot_timer = 2.5 if phase == 1 else 1.9
		_shoot_fan(3 if phase == 1 else 5)
	if phase == 2:
		_summon_timer -= delta
		if _summon_timer <= 0.0:
			_summon_timer = 6.0
			_summon()

func _check_bridge() -> bool:
	for b in get_tree().get_nodes_in_group("bridge"):
		if is_instance_valid(b) and b.global_position.distance_to(global_position) < 260.0:
			return true
	return false

func _break_shield() -> void:
	shield = false
	_shield_timer = 8.0
	AudioManager.play_sfx("puzzle_correct")
	EventBus.message.emit("Perisai pecah! Serang Null Sovereign selama 8 detik.")

func _shoot_fan(count: int) -> void:
	if player == null or not is_instance_valid(player):
		return
	var base := (player.global_position - global_position).normalized()
	var spread := deg_to_rad(18)
	for i in count:
		var orb := ORB.instantiate()
		orb.global_position = global_position
		var angle := (i - (count - 1) / 2.0) * spread
		orb.direction = base.rotated(angle)
		orb.damage = 1
		orb.owner_group = "boss_orb"
		get_parent().add_child(orb)
	AudioManager.play_sfx("skill")

func _summon() -> void:
	var scn := preload("res://scenes/enemies/orphan_glitch.tscn")
	for i in 2:
		var e := scn.instantiate()
		e.global_position = global_position + Vector2(-40 + i * 80, -40)
		get_parent().add_child(e)
	EventBus.message.emit("Null Sovereign memunculkan Orphan Glitch!")

func take_hit(amount: int, _dir: int = 1) -> void:
	if _dead:
		return
	if shield:
		EventBus.message.emit("Perisai menolak serangan. Buat Relation Bridge yang valid dulu.")
		AudioManager.play_sfx("puzzle_wrong")
		return
	hp -= amount
	hp_bar.value = hp
	AudioManager.play_sfx("hurt")
	sprite.modulate = Color(1, 0.5, 0.6)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)
	if hp <= 0:
		_die()

func _die() -> void:
	_dead = true
	GameState.add_xp(300)
	GameState.solve_puzzle("L3_BOSS", 3, 0)
	GameState.complete_level("L3")
	EventBus.boss_defeated.emit("null_sovereign")
	AudioManager.play_sfx("victory")
	EventBus.message.emit("NULL SOVEREIGN hancur. Schema pulih!")
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(2, 2, 2, 0), 1.0)
	await t.finished
	SaveManager.save_game()
	RoomManager.goto_end_session(true)

func hit_damage() -> int:
	return damage