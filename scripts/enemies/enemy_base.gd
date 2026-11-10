extends CharacterBody2D
## EnemyBase - musuh umum (GDD 3.5). Perilaku dipilih lewat export `behavior`.
## patrol  : jalan kiri-kanan, balik di tepi/dinding
## hop     : patrol + lompat kecil tiap 2 detik
## chase   : mengejar pemain perlahan
## charge  : menerjang bolak-balik (Guardian)

signal died(kind: String, pos: Vector2)

const GRAVITY := 800.0

@export var kind := "glitch_blob"
@export var max_hp := 3
@export var damage := 1
@export var speed := 30.0
@export var behavior := "patrol"
@export var is_guardian := false
@export var is_boss := false
@export var drop_key := ""
@export var split_on_death := false
@export var xp_reward := 3

var hp := 3
var facing := -1
var player: Node2D = null
var _dead := false
var _hop_timer := 0.0
var _stun := 0.0
var _summoned := 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var wall_ray: RayCast2D = $WallRay
@onready var ledge_ray: RayCast2D = $LedgeRay
@onready var hp_bar: ProgressBar = $HpBar
@onready var shape_node: CollisionShape2D = $CollisionShape2D

## Tabel varian: frame, hp, damage, speed, perilaku, ukuran collision.
const VARIANTS := {
	"glitch_blob": ["res://assets/sprites/enemies/glitch_blob_frames.tres", 3, 1, 30.0, "patrol", Vector2(12, 12)],
	"duplicate_slime": ["res://assets/sprites/enemies/duplicate_slime_frames.tres", 4, 1, 26.0, "hop", Vector2(12, 12)],
	"orphan_glitch": ["res://assets/sprites/enemies/orphan_glitch_frames.tres", 2, 1, 50.0, "chase", Vector2(12, 12)],
	"duplicate_golem": ["res://assets/sprites/enemies/duplicate_golem_frames.tres", 20, 1, 40.0, "charge", Vector2(20, 26)],
	"composite_warden": ["res://assets/sprites/enemies/composite_warden_frames.tres", 25, 1, 18.0, "patrol", Vector2(20, 26)],
}

func _apply_variant() -> void:
	if not VARIANTS.has(kind):
		return
	var v: Array = VARIANTS[kind]
	sprite.sprite_frames = load(v[0])
	max_hp = int(v[1])
	damage = int(v[2])
	speed = float(v[3])
	behavior = String(v[4])
	var rect := RectangleShape2D.new()
	rect.size = v[5]
	shape_node.shape = rect
	shape_node.position = Vector2(0, -float(v[5].y) * 0.5)
	is_guardian = is_guardian or kind in ["duplicate_golem", "composite_warden"]
	if kind == "duplicate_slime":
		split_on_death = true
	if is_guardian:
		xp_reward = 150

func _ready() -> void:
	add_to_group("enemy")
	_apply_variant()
	if is_guardian:
		add_to_group("guardian")
	if kind == "composite_warden":
		add_to_group("warden")
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.visible = is_guardian or is_boss
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, 380.0)
	if _stun > 0.0:
		_stun -= delta
		velocity.x = move_toward(velocity.x, 0.0, 400 * delta)
		move_and_slide()
		return
	match behavior:
		"patrol": _do_patrol()
		"hop": _do_hop(delta)
		"chase": _do_chase()
		"charge": _do_charge()
	move_and_slide()
	if behavior != "chase":
		_turn_at_edges()

func _do_patrol() -> void:
	velocity.x = facing * speed

func _do_hop(delta: float) -> void:
	_do_patrol()
	_hop_timer -= delta
	if _hop_timer <= 0.0 and is_on_floor():
		velocity.y = -180.0
		_hop_timer = 2.0

func _do_chase() -> void:
	if player == null or not is_instance_valid(player):
		velocity.x = 0.0
		return
	var d := player.global_position - global_position
	velocity.x = signf(d.x) * speed if absf(d.x) > 8.0 else 0.0
	facing = 1 if d.x > 0 else -1

func _do_charge() -> void:
	velocity.x = facing * speed
	if wall_ray.is_colliding():
		facing *= -1
	elif not ledge_ray.is_colliding() and is_on_floor():
		facing *= -1
	sprite.flip_h = facing < 0

func _turn_at_edges() -> void:
	sprite.flip_h = facing < 0
	if is_on_floor() and not ledge_ray.is_colliding():
		facing *= -1
	elif wall_ray.is_colliding():
		facing *= -1

## ---------- damage masuk ----------
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("hurt") and area.is_in_group("player"):
		area.hurt(damage, global_position)

func take_hit(amount: int, _dir: int = 1) -> void:
	if _dead:
		return
	hp -= amount
	if hp_bar != null:
		hp_bar.value = hp
	AudioManager.play_sfx("hurt")
	_flash()
	if hp <= 0:
		_die()
		return
	if is_guardian and hp <= max_hp * 0.75 * (_summoned + 1) and _summoned < 3:
		_summon_minion()

func _flash() -> void:
	sprite.modulate = Color(1, 0.4, 0.4)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.18)

func _summon_minion() -> void:
	_summoned += 1
	var scn: PackedScene = load("res://scenes/enemies/glitch_blob.tscn")
	var e: Node = scn.instantiate()
	e.global_position = global_position + Vector2(-28, -8)
	get_parent().add_child(e)
	EventBus.message.emit("Duplicate Golem memanggil minion!")

func _die() -> void:
	_dead = true
	died.emit(kind, global_position)
	GameState.add_xp(xp_reward)
	_drop_loot()
	if split_on_death:
		_split()
	AudioManager.play_sfx("death")
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.25)
	await t.finished
	queue_free()

func _drop_loot() -> void:
	var scn := preload("res://scenes/items/pickup.tscn")
	var n := randi_range(2, 4)
	for i in n:
		var p := scn.instantiate()
		p.kind = "fragment"
		p.collectible_id = ""
		p.amount = 1
		p.global_position = global_position + Vector2(randf_range(-10, 10), -6)
		get_parent().add_child(p)
	if randf() < 0.25:
		var e := scn.instantiate()
		e.kind = "energy_cell"
		e.collectible_id = ""
		e.global_position = global_position + Vector2(randf_range(-6, 6), -10)
		get_parent().add_child(e)
	if drop_key != "":
		var k := scn.instantiate()
		k.kind = "schema_key"
		k.collectible_id = drop_key
		k.global_position = global_position + Vector2(0, -8)
		get_parent().add_child(k)
	if is_guardian:
		var c := scn.instantiate()
		c.kind = "logic_core"
		c.collectible_id = ""
		c.global_position = global_position + Vector2(12, -8)
		get_parent().add_child(c)

func _split() -> void:
	var scn: PackedScene = load("res://scenes/enemies/duplicate_slime.tscn")
	for i in 2:
		var e: Node = scn.instantiate()
		e.max_hp = 1
		e.speed = 42.0
		e.split_on_death = false
		e.xp_reward = 0
		e.global_position = global_position + Vector2(-14 + i * 28, -4)
		get_parent().add_child(e)

func stun(seconds: float) -> void:
	_stun = seconds
	sprite.modulate = Color(0.6, 0.8, 1.0)

func hit_damage() -> int:
	return damage
