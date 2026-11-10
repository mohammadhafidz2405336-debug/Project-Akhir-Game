extends CharacterBody2D
## Player - Data Explorer. Gerak sesuai GDD 1.4, serangan Data Slash, 3 skill.

const RUN_SPEED := 110.0
const GRAVITY := 800.0
const JUMP_VELOCITY := -260.0
const JUMP_CUT := 0.5
const MAX_FALL_SPEED := 380.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.10
const HURT_IFRAMES := 1.2
const KNOCKBACK := Vector2(120, -140)
const BASE_DAMAGE := 2
const ATTACK_CD := 0.35

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $AttackPivot/Hitbox
@onready var attack_pivot: Node2D = $AttackPivot
@onready var coyote: Timer = $CoyoteTimer
@onready var jump_buffer: Timer = $JumpBufferTimer
@onready var iframes: Timer = $IFrameTimer
@onready var attack_cd: Timer = $AttackCooldown

var facing := 1
var _dead := false
var _attacking := false
var _can_attack := true
var _hurt_locked := false
var _energy_delay := 0.0
var _spawn_point := Vector2.ZERO
var interacting: Node = null

func _ready() -> void:
	add_to_group("player")
	_spawn_point = global_position
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	GameState.set_health(GameState.health)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if _dead:
		return
	var dir := Input.get_axis("move_left", "move_right")
	if not _hurt_locked:
		velocity.x = move_toward(velocity.x, dir * RUN_SPEED, 900 * delta)
		if absf(dir) > 0.1:
			facing = signi(int(dir))
			attack_pivot.scale.x = facing
			sprite.flip_h = facing < 0
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	if is_on_floor():
		coyote.start(COYOTE_TIME)
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start(JUMP_BUFFER)
	if jump_buffer.time_left > 0.0 and (coyote.time_left > 0.0 or is_on_floor()):
		velocity.y = JUMP_VELOCITY
		jump_buffer.stop()
		coyote.stop()
		AudioManager.play_sfx("jump")
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT
	move_and_slide()
	_update_animation(dir)
	if Input.is_action_just_pressed("attack"):
		_attack()
	if Input.is_action_just_pressed("interact"):
		_interact()
	_regen_energy(delta)

func _process(delta: float) -> void:
	if _dead or get_tree().paused:
		return
	if Input.is_action_just_pressed("skill_1"):
		_cast_scan()
	elif Input.is_action_just_pressed("skill_3"):
		_cast_strike()
	elif Input.is_action_just_pressed("skill_5"):
		_cast_bridge()
	if global_position.y > 1200:  # jatuh ke void
		_fall_off()

func _regen_energy(delta: float) -> void:
	_energy_delay = maxf(0.0, _energy_delay - delta)
	if _energy_delay <= 0.0 and GameState.energy < GameState.energy_max:
		GameState.add_energy(3.0 * GameState.difficulty_regen_mult() * delta)

func _update_animation(dir: float) -> void:
	if _attacking or _hurt_locked:
		return
	if not is_on_floor():
		sprite.play("fall" if velocity.y > 0 else "jump")
	elif absf(dir) > 0.1:
		sprite.play("run")
	else:
		sprite.play("idle")

## ---------- serangan ----------
func _attack() -> void:
	if not _can_attack or _hurt_locked or _dead:
		return
	_can_attack = false
	_attacking = true
	sprite.play("attack")
	attack_cd.start(ATTACK_CD)
	AudioManager.play_sfx("attack")
	hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(hitbox):
		hitbox.monitoring = false
	_attacking = false

func damage_amount() -> int:
	return BASE_DAMAGE + MarketManager.damage_bonus() + GameState.damage_tier

func _on_attack_cooldown_timeout() -> void:
	_can_attack = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		area.take_hit(damage_amount(), facing)

## ---------- menerima damage ----------
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if iframes.time_left > 0.0 or _dead:
		return
	if area.has_method("hit_damage"):
		hurt(area.hit_damage(), area.global_position)

func hurt(amount: int, from: Vector2) -> void:
	if iframes.time_left > 0.0 or _dead:
		return
	GameState.damage(maxi(1, amount))
	iframes.start(HURT_IFRAMES)
	sprite.play("hurt")
	AudioManager.play_sfx("hurt")
	_hurt_locked = true
	var kb := KNOCKBACK
	kb.x = KNOCKBACK.x * (-1.0 if from.x > global_position.x else 1.0)
	velocity = kb
	_flash()
	await get_tree().create_timer(0.25).timeout
	if is_instance_valid(self):
		_hurt_locked = false
		sprite.play("idle")

func _flash() -> void:
	sprite.modulate = Color(1, 0.5, 0.5)
	var t := create_tween()
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.3)

## ---------- interact ----------
func _interact() -> void:
	if interacting != null and is_instance_valid(interacting) and interacting.has_method("interact"):
		interacting.interact(self)

## ---------- skill ----------
func _cast_scan() -> void:
	if not SkillManager.pay("scan"):
		_skill_denied("scan")
		return
	_energy_delay = 1.5
	sprite.play("cast")
	var wave := preload("res://scenes/skills/scan_wave.tscn").instantiate()
	wave.global_position = global_position
	get_parent().add_child(wave)

func _cast_strike() -> void:
	if not SkillManager.pay("strike"):
		_skill_denied("strike")
		return
	_energy_delay = 1.5
	sprite.play("attack")
	var strike := preload("res://scenes/skills/unique_strike.tscn").instantiate()
	strike.setup(facing, damage_amount() * 2)
	strike.global_position = global_position + Vector2(16 * facing, -4)
	get_parent().add_child(strike)
	velocity.x = 80.0 * facing

func _cast_bridge() -> void:
	if not SkillManager.pay("bridge"):
		_skill_denied("bridge")
		return
	_energy_delay = 1.5
	var anchors := get_tree().get_nodes_in_group("relation_anchor")
	var nearest = null
	var best := 128.0
	for a in anchors:
		if not a.has_method("is_selectable") or not a.is_selectable():
			continue
		var d := global_position.distance_to(a.global_position)
		if d < best:
			best = d
			nearest = a
	if nearest == null:
		EventBus.message.emit("Tidak ada anchor dalam jangkauan (maks 128 px).")
		return
	nearest.toggle_selected()

func _skill_denied(id: String) -> void:
	if not SkillManager.is_unlocked(id):
		EventBus.message.emit("Skill belum diperoleh.")
	elif SkillManager.cooldown_left(id) > 0.0:
		EventBus.message.emit("Skill masih cooldown.")
	else:
		EventBus.message.emit("Energy tidak cukup.")

## ---------- kematian ----------
func _fall_off() -> void:
	GameState.damage(1)
	if GameState.health > 0:
		global_position = RoomManager.last_checkpoint if RoomManager.last_checkpoint != Vector2.ZERO else _spawn_point
		velocity = Vector2.ZERO
	elif not _dead:
		die()

func die() -> void:
	if _dead:
		return
	_dead = true
	sprite.play("death")
	AudioManager.play_sfx("death")
	await get_tree().create_timer(1.2).timeout
	RoomManager.goto_end_session(false)

func on_player_died() -> void:
	die()

func set_checkpoint(pos: Vector2) -> void:
	_spawn_point = pos
	RoomManager.set_checkpoint(RoomManager.current_level, pos)
