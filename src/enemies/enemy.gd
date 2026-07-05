extends Node2D
## Enemy: walks along the world path. Takes damage from towers/projectiles.
## Uses progress (0..1) along the path so towers can target the leader.

signal reached_exit(enemy: Node2D)
signal died(enemy: Node2D)

@export var data: EnemyData

var hp: float = 30.0
var progress: float = 0.0       # distance travelled along the path
var _path: Array[Vector2] = []
var _total_length: float = 1.0
var _alive: bool = true
var _slow_timer: float = 0.0
var _slow_factor: float = 1.0
# Idle bob: each enemy gets a random phase so a swarm doesn't bob in unison.
var _bob_phase: float = 0.0
var _bob_base_y: float = 0.0

@onready var sprite: Node2D = $Sprite
@onready var hp_bar_bg: ColorRect = $HPBarBG
@onready var hp_bar: ColorRect = $HPBar


func _ready() -> void:
	add_to_group("enemies")
	_bob_phase = randf() * TAU
	_bob_base_y = sprite.position.y if sprite else 0.0
	if data:
		_apply_data()


func configure(d: EnemyData, path: Array[Vector2], total_length: float) -> void:
	data = d
	_path = path
	_total_length = max(1.0, total_length)
	hp = d.max_hp
	if is_inside_tree():
		_apply_data()


func _apply_data() -> void:
	# Pixel-art sprite: bigger enemies (dragon) render at higher pixel scale.
	# Scaled down for the 32px tile grid (was 4/5/6 on the 64px grid).
	var psize: float = 2.0
	if data.radius >= 24:
		psize = 3.0
	elif data.radius >= 18:
		psize = 3.0
	if sprite and sprite is PixelSprite:
		sprite.configure(PixelArt.for_enemy(data.id), PixelArt.PALETTE, psize)
	# HP bar sits just above the sprite's head. Base the height on the ACTUAL
	# rendered sprite height (rows * pixel_size), not the logical radius —
	# otherwise the bar ends up hidden inside tall sprites like the skeleton.
	var sprite_h := 16.0 * psize   # patterns are 16 rows (some fewer, close enough)
	var bar_w := maxi(data.radius * 2, 28)
	hp_bar_bg.size = Vector2(bar_w, 5)
	hp_bar_bg.position = Vector2(-bar_w * 0.5, -sprite_h * 0.5 - 10)
	hp_bar_bg.color = Color(0.08, 0.05, 0.05)
	hp_bar.size = Vector2(bar_w, 5)
	hp_bar.position = hp_bar_bg.position
	hp_bar.color = Color(0.9, 0.3, 0.3)
	_update_hp_bar()


func is_alive() -> bool:
	return _alive


func take_damage(amount: float) -> void:
	if not _alive:
		return
	var dmg: float = max(0.0, amount - (data.armor if data else 0.0))
	hp -= dmg
	_update_hp_bar()
	_hit_feedback(dmg)
	if hp <= 0.0:
		_die()


## Squash + white flash + floating damage number on every hit.
func _hit_feedback(dmg: float) -> void:
	FX.damage_number(global_position + Vector2(0, -6), dmg,
			Color(1, 0.95, 0.5))
	SFX.hit()
	if sprite:
		# Brief "blown out" white tint for a crunchy hit, then ease back.
		var orig_mod := sprite.modulate
		sprite.modulate = Color(2.5, 2.5, 2.5)
		var tw := create_tween()
		tw.tween_property(sprite, "modulate", orig_mod, 0.10)
		# Squash & stretch: snap small, ease back — sells the impact.
		var orig_scale := sprite.scale
		sprite.scale = orig_scale * Vector2(1.25, 0.8)
		var sq := create_tween()
		sq.tween_property(sprite, "scale", orig_scale, 0.12).set_ease(Tween.EASE_OUT)


func apply_slow(factor: float, duration: float) -> void:
	# Keep the strongest slow; refresh duration.
	_slow_factor = min(_slow_factor, factor)
	_slow_timer = max(_slow_timer, duration)


func _process(dt: float) -> void:
	if not _alive or _path.is_empty():
		return
	# Idle bob: a small vertical sine so the sprite feels alive. Amplitude scales
	# with enemy size (dragons/lab bosses breathe, small foes trot). This only
	# touches sprite.position.y; the hit squash uses scale/modulate, so no clash.
	if sprite:
		var t := Time.get_ticks_msec() * 0.003 + _bob_phase
		var amp: float = 1.5 if (data and data.radius < 20) else 2.5
		sprite.position.y = _bob_base_y + sin(t) * amp
	# Regeneration (Trolls): heal back up over time, capped at max HP. The slow
	# burn is what makes regen enemies scary — they undo chip damage.
	if data and data.regen > 0.0 and hp < data.max_hp:
		hp = min(data.max_hp, hp + data.regen * dt)
		_update_hp_bar()
	# Resolve current speed
	var speed_mult := 1.0
	if _slow_timer > 0.0:
		_slow_timer -= dt
		speed_mult = _slow_factor
		if _slow_timer <= 0.0:
			_slow_factor = 1.0
	var move := data.speed * speed_mult * dt
	progress += move
	# Walk along segments
	var remaining := progress
	for i in range(1, _path.size()):
		var seg_len := _path[i].distance_to(_path[i - 1])
		if remaining <= seg_len:
			var t: float = remaining / max(0.0001, seg_len)
			global_position = _path[i - 1].lerp(_path[i], t)
			return
		remaining -= seg_len
	# Reached the end
	global_position = _path[-1]
	_reach_exit()


func _reach_exit() -> void:
	if not _alive:
		return
	_alive = false
	reached_exit.emit(self)
	var leak: int = data.leaks_damage if data else 1
	for i in leak:
		GameManager.enemy_leaked()
	# Red "leak" ring + light shake so a leak always reads as bad news.
	FX.ring(global_position, Color(0.95, 0.25, 0.25), 36.0)
	FX.screen_shake(4.0, 0.15)
	SFX.leak()
	queue_free()


func _die() -> void:
	if not _alive:
		return
	_alive = false
	died.emit(self)
	# Death pop: colored shards + soft flash. Bigger enemies burst harder.
	var col: Color = data.color if data else Color.WHITE
	var shards: int = 8
	if data and data.radius >= 18:
		shards = 12
	if data and data.radius >= 24:
		shards = 16
	FX.burst(global_position, col, shards, 90.0)
	FX.flash_at(global_position, Color(col.r + 0.5, col.g + 0.5, col.b + 0.5), 18.0)
	# Bigger enemies shake the screen more on death.
	if data and data.radius >= 24:
		FX.screen_shake(7.0, 0.28)
		FX.freeze_frame(0.06)
		SFX.boss_die()
	elif data and data.radius >= 18:
		FX.screen_shake(3.0, 0.15)
		SFX.enemy_die()
	else:
		SFX.enemy_die()
	if data:
		GameManager.earn(data.gold_reward)
	queue_free()


func _update_hp_bar() -> void:
	if not data or not hp_bar:
		return
	var pct: float = clamp(hp / data.max_hp, 0.0, 1.0)
	var bar_w := maxi(data.radius * 2, 28)
	hp_bar.size.x = bar_w * pct
	# Show the HP bar only when the enemy is actually hurt — a screen full of
	# full red bars is noise; this way bars only appear when they carry info.
	var show := pct < 1.0
	hp_bar.visible = show
	hp_bar_bg.visible = show
	# Color shifts green -> yellow -> red as health drops, for at-a-glance triage.
	if pct > 0.6:
		hp_bar.color = Color(0.45, 0.85, 0.40)
	elif pct > 0.3:
		hp_bar.color = Color(0.95, 0.80, 0.30)
	else:
		hp_bar.color = Color(0.95, 0.30, 0.25)
