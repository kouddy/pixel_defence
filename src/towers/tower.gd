extends Node2D
## Tower: a placed defender unit. Acquires targets in range, fires projectiles
## (or melee-hits) on a cooldown. Splash towers damage all enemies in a radius.
##
## Upgrades: each tower tracks its level (0..Upgrades.MAX) and the cumulative
## gold invested (used for the sell refund). upgrade() re-applies all tiers from
## the BASE stats so multipliers stack cleanly rather than compounding drift.

signal changed(tower: Node2D)   # emitted on upgrade/sell-state change for UI

# Targeting modes the player can cycle on a selected tower.
enum TargetMode { FIRST, LAST, STRONGEST }
const TARGET_MODE_NAMES := { TargetMode.FIRST: "First", TargetMode.LAST: "Last", TargetMode.STRONGEST: "Strong" }

@export var data: UnitData

var _cooldown: float = 0.0
var _enemies: Array = []   # injected by GameWorld each frame via set_enemies
var _show_range: bool = false
var target_mode: int = TargetMode.FIRST   # player-selected targeting priority

# Upgrade state.
var level: int = 0                       # 0 = base, up to Upgrades.MAX_LEVEL
var invested_gold: int = 0               # total gold sunk into this tower
var _base: UnitData = null               # snapshot of base stats at placement
# Idle sway phase (random per-tower so a row of towers doesn't move in sync).
var _sway_phase: float = 0.0

@onready var sprite: Node2D = $Sprite
@onready var range_visual: ColorRect = $RangeVisual


func _ready() -> void:
	_sway_phase = randf() * TAU
	if data:
		_apply_data()
	range_visual.visible = false


func _apply_data() -> void:
	if sprite and sprite is PixelSprite:
		sprite.configure(PixelArt.for_unit(data.id), PixelArt.PALETTE, 2.0)
	# Range preview rect sized to range.
	if range_visual:
		var rs := data.range_px * 2
		range_visual.size = Vector2(rs, rs)
		range_visual.position = -range_visual.size * 0.5


func configure(unit_data: UnitData) -> void:
	data = unit_data
	# Snapshot the base stats once — upgrades recompute from this so multipliers
	# stack deterministically instead of drifting on repeat reapplication.
	if _base == null:
		_base = unit_data.duplicate()
		invested_gold = unit_data.cost
	if is_inside_tree():
		_apply_data()


func set_enemies(list: Array) -> void:
	_enemies = list


func show_range(v: bool) -> void:
	_show_range = v
	if range_visual:
		range_visual.visible = v


# ============================ UPGRADES ============================

## Attempt to upgrade one level. Returns true on success. Caller pays gold.
func upgrade() -> bool:
	if _base == null:
		return false
	var tiers := Upgrades.tiers_for(_base.id)
	if level >= tiers.size():
		return false
	level += 1
	invested_gold += tiers[level - 1][&"cost"]
	_recompute_stats()
	_upgrade_fx()
	changed.emit(self)
	return true


## Cost to buy the next level, or -1 if already maxed.
func next_upgrade_cost() -> int:
	if _base == null:
		return -1
	return Upgrades.next_cost(_base.id, level)


func is_maxed() -> bool:
	if _base == null:
		return true
	return Upgrades.is_maxed(_base.id, level)


## Refund 70% of invested gold when selling — standard TD convention so
## repositioning is possible but not free.
func sell_value() -> int:
	return int(invested_gold * 0.7)


## Human-readable description of the next tier's effect, for the UI panel.
func next_tier_note() -> String:
	if _base == null:
		return ""
	var tiers := Upgrades.tiers_for(_base.id)
	if level >= tiers.size():
		return "Maximum rank reached."
	return tiers[level][&"note"]


## Recompute current stats from base + all applied tiers.
func _recompute_stats() -> void:
	if _base == null:
		return
	var d := _base.duplicate()
	var dmg_mult := 1.0
	var range_mult := 1.0
	var rate_mult := 1.0
	var splash_mult := 1.0
	var tiers := Upgrades.tiers_for(_base.id)
	for i in level:
		var t: Dictionary = tiers[i]
		dmg_mult *= t[&"damage"]
		range_mult *= t[&"range"]
		rate_mult *= t[&"fire_rate"]
		splash_mult *= t.get(&"splash", 1.0)
	d.damage = _base.damage * dmg_mult
	d.range_px = _base.range_px * range_mult
	d.fire_rate = _base.fire_rate * rate_mult
	d.splash_radius = _base.splash_radius * splash_mult
	data = d
	_apply_data()


func _upgrade_fx() -> void:
	# A satisfying "level up" pop: golden flash + ring + brief scale bounce.
	FX.flash_at(global_position, Color(1.0, 0.92, 0.45), 20.0)
	FX.ring(global_position, Color(1.0, 0.85, 0.35), 42.0)
	SFX.place()
	if sprite:
		var orig := sprite.scale
		var tw := create_tween()
		tw.tween_property(sprite, "scale", orig * 1.3, 0.08).set_ease(Tween.EASE_OUT)
		tw.tween_property(sprite, "scale", orig, 0.14)


# ============================ COMBAT ============================




func _process(dt: float) -> void:
	# Idle sway: a tiny rotational breathe so towers feel alive, not pasted on.
	# Uses rotation (never touched by recoil/muzzle tweens, which animate position
	# and scale) so there's no conflict.
	if sprite:
		var t := Time.get_ticks_msec() * 0.0015 + _sway_phase
		sprite.rotation = sin(t) * 0.04
	_cooldown -= dt
	if _cooldown > 0.0:
		return
	var target := _acquire_target()
	if target == null:
		return
	_fire(target)


func _acquire_target() -> Node2D:
	# Pick the in-range enemy that best matches the tower's targeting priority.
	var best: Node2D = null
	var best_score: float = -INF
	for e in _enemies:
		if not is_instance_valid(e):
			continue
		if not e.is_alive():
			continue
		if e.data.is_flying and not data.can_hit_air:
			continue
		if global_position.distance_to(e.global_position) > data.range_px:
			continue
		# Higher score = preferred target. Each mode maps the enemy's relevant
		# stat onto a comparable scale.
		var score: float
		match target_mode:
			TargetMode.FIRST:
				# Closest to the exit = most progress along the path.
				score = e.progress
			TargetMode.LAST:
				# Furthest from exit = least progress (newest spawn in range).
				score = -e.progress
			TargetMode.STRONGEST:
				# Highest current HP; tiebreak by progress so it still prefers
				# the leader among equals.
				score = e.hp * 1000.0 + e.progress
			_:
				score = e.progress
		if score > best_score:
			best_score = score
			best = e
	return best


## Cycle to the next targeting mode. Called from the HUD panel buttons.
func cycle_target_mode() -> void:
	target_mode = (target_mode + 1) % TARGET_MODE_NAMES.size()
	changed.emit(self)


func target_mode_label() -> String:
	return TARGET_MODE_NAMES.get(target_mode, "?")


func _fire(target: Node2D) -> void:
	_cooldown = 1.0 / max(0.0001, data.fire_rate)
	match data.attack_type:
		UnitData.AttackType.MELEE:
			_apply_damage([target])
			_play_melee_fx(target)
		UnitData.AttackType.PROJECTILE:
			_spawn_projectile(target)
		UnitData.AttackType.SPLASH:
			_spawn_projectile(target, true)


## Visible feedback for melee: a quick lunge toward the target + a slash arc.
func _play_melee_fx(target: Node2D) -> void:
	if not is_instance_valid(target):
		return
	SFX.hit()   # melee connect sound
	# Slash arc drawn briefly at the target position.
	var slash := ColorRect.new()
	slash.color = Color(1, 0.95, 0.8, 0.9)
	slash.size = Vector2(14, 14)
	slash.position = -slash.size * 0.5
	slash.rotation = randf() * TAU
	get_tree().current_scene.add_child(slash)
	slash.global_position = target.global_position
	var tw := create_tween()
	tw.tween_property(slash, "scale", Vector2(1.8, 1.8), 0.12)
	tw.parallel().tween_property(slash, "modulate:a", 0.0, 0.12)
	tw.tween_callback(slash.queue_free)
	# Lunge the tower sprite toward the enemy a touch, then back.
	if sprite:
		var dir: Vector2 = (target.global_position - global_position).normalized()
		var orig := sprite.position
		var lunge := tw
		# Use a separate tween so it doesn't block the slash cleanup.
		var st := create_tween()
		st.tween_property(sprite, "position", orig + dir * 6.0, 0.06)
		st.tween_property(sprite, "position", orig, 0.10)


func _spawn_projectile(target: Node2D, splash: bool = false) -> void:
	var proj := preload("res://src/towers/projectile.tscn").instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.configure(target, data.damage, data.projectile_speed, data.color,
			splash, data.splash_radius, data.slows_on_hit,
			data.slow_factor, data.slow_duration)
	# Muzzle flash + recoil pop toward the target, so each shot has weight.
	FX.flash_at(global_position, data.color, 10.0)
	SFX.shoot()
	if sprite:
		var orig := sprite.position
		var dir: Vector2 = (target.global_position - global_position).normalized()
		var tw := create_tween()
		tw.tween_property(sprite, "position", orig - dir * 4.0, 0.04)
		tw.tween_property(sprite, "position", orig, 0.12)


func _apply_damage(targets: Array) -> void:
	for t in targets:
		if is_instance_valid(t) and t.has_method("take_damage"):
			t.take_damage(data.damage)
			if data.slows_on_hit and t.has_method("apply_slow"):
				t.apply_slow(data.slow_factor, data.slow_duration)


# Range drawn as a crisp circle outline instead of the placeholder rect.
func _draw() -> void:
	if _show_range and data:
		draw_arc(Vector2.ZERO, data.range_px, 0, TAU, 48, Color(1, 1, 1, 0.35), 1.5)
