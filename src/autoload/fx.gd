extends Node
## FX (autoload singleton)
## Centralized game-feel: screen shake, floating damage numbers, hitstop,
## and death bursts. Anything in the game calls FX.screen_shake(...) etc.
##
## Owns a Camera2D in fixed-top-left mode so the world stays aligned to the
## top-left corner (same as the no-camera layout) while we shake its offset.

const DAMAGE_NUMBER_SCENE := preload("res://src/fx/damage_number.tscn")
const BURST_SHARD_SCENE := preload("res://src/fx/burst_shard.tscn")

var _cam: Camera2D = null
var _shake_remaining: float = 0.0
var _shake_intensity: float = 0.0
var _freeze_remaining: float = 0.0
# Track whether FX itself owns the current tree-pause, so the hitstop's
# auto-unpause never releases a pause that the PLAYER requested (and vice versa).
var _fx_owns_pause: bool = false
# True when the player has paused. FX must not unpause the tree while this is set.
var player_paused: bool = false

# World-space nodes are added under the current scene root so they move with
# the camera shake (since the camera shakes everything in the scene).
func _ready() -> void:
	# Run during pause so we can run our own hitstop and un-pause the tree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cam = Camera2D.new()
	_cam.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	_cam.position = Vector2.ZERO
	add_child(_cam)
	_cam.make_current.call_deferred()
	process_priority = -100   # run FX updates before gameplay code


func _process(dt: float) -> void:
	# Hitstop: pause the whole scene tree for a few frames so the impact lands.
	# FX itself keeps running (PROCESS_MODE_ALWAYS) so it can release the pause.
	if _freeze_remaining > 0.0:
		_freeze_remaining -= dt
		if _freeze_remaining <= 0.0:
			_freeze_remaining = 0.0
			# Only release the pause if FX owns it AND the player hasn't paused.
			if _fx_owns_pause and not player_paused:
				get_tree().paused = false
			_fx_owns_pause = false
		# Keep the shake at full magnitude while frozen — no decay.
		return
	if _shake_remaining > 0.0:
		_shake_remaining -= dt
		var falloff: float = clamp(_shake_remaining / 0.3, 0.0, 1.0)
		var mag: float = _shake_intensity * falloff
		_cam.offset = Vector2(randf_range(-mag, mag), randf_range(-mag, mag))
		if _shake_remaining <= 0.0:
			_cam.offset = Vector2.ZERO
			_shake_intensity = 0.0
	else:
		_cam.offset = Vector2.ZERO


# ============================ SCREEN SHAKE ============================

func screen_shake(intensity: float = 6.0, duration: float = 0.25) -> void:
	# No new feel-events while the player has paused the game.
	if player_paused:
		return
	# Keep the strongest shake if a new one is weaker than the active one.
	if intensity < _shake_intensity and _shake_remaining > 0.0:
		return
	_shake_intensity = max(_shake_intensity, intensity)
	_shake_remaining = max(_shake_remaining, duration)


func freeze_frame(duration: float = 0.05) -> void:
	# Never trigger a gameplay hitstop while the player paused — it would
	# fight the player's pause state.
	if player_paused:
		return
	# A short global hitstop. Tiny values (40-60ms) sell impacts without feeling laggy.
	_freeze_remaining = max(_freeze_remaining, duration)
	if not get_tree().paused:
		get_tree().paused = true
		_fx_owns_pause = true


# ============================ DAMAGE NUMBERS ============================

func damage_number(world_pos: Vector2, amount: float, col: Color = Color(1, 0.95, 0.5)) -> void:
	var label := DAMAGE_NUMBER_SCENE.instantiate()
	_get_container().add_child(label)
	label.global_position = world_pos + Vector2(randf_range(-6, 6), -10)
	if label.has_method("setup"):
		label.setup(amount, col)


# ============================ DEATH / HIT BURSTS ============================

## A burst of colored shards flying outward — used for enemy deaths and big hits.
func burst(world_pos: Vector2, col: Color, shards: int = 8, spread: float = 120.0) -> void:
	var container := _get_container()
	for i in shards:
		var shard := BURST_SHARD_SCENE.instantiate()
		container.add_child(shard)
		shard.global_position = world_pos
		var ang: float = (float(i) / shards) * TAU + randf_range(-0.3, 0.3)
		var dist: float = randf_range(spread * 0.5, spread)
		if shard.has_method("launch"):
			shard.launch(col, Vector2(cos(ang), sin(ang)) * dist)


## A quick expanding ring — used for splash impacts and leaks.
func ring(world_pos: Vector2, col: Color, max_radius: float = 40.0) -> void:
	var node := _draw_node()
	_get_container().add_child(node)
	node.global_position = world_pos
	node.draw_fn = func(r: float, alpha: float) -> void:
		node.draw_arc(Vector2.ZERO, r, 0, TAU, 36, Color(col.r, col.g, col.b, alpha), 2.5)
	var tw := node.create_tween()
	tw.tween_method(node._set_radius, 4.0, max_radius, 0.28)
	tw.parallel().tween_method(node._set_alpha, 0.9, 0.0, 0.28)
	tw.tween_callback(node.queue_free)


func flash_at(world_pos: Vector2, col: Color, size: float = 16.0) -> void:
	# A one-shot expanding soft flash. Useful for muzzle flashes and small hits.
	var container := _get_container()
	var fx := ColorRect.new()
	fx.color = col
	fx.size = Vector2(size, size)
	fx.position = -fx.size * 0.5
	container.add_child(fx)
	fx.global_position = world_pos
	var tw := fx.create_tween()
	tw.tween_property(fx, "scale", Vector2(2.2, 2.2), 0.14).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(fx, "modulate:a", 0.0, 0.14)
	tw.tween_callback(fx.queue_free)


# ============================ INTERNAL ============================

func _get_container() -> Node:
	# Add transient FX under the current scene so they inherit the camera.
	return get_tree().current_scene


func _draw_node() -> Node2D:
	# Lazy helper: a tiny node that exposes a draw_fn + radius/alpha for ring().
	var n := _RingDrawer.new()
	return n


class _RingDrawer:
	extends Node2D
	var radius: float = 4.0
	var alpha: float = 0.9
	var draw_fn: Callable = Callable()
	func _set_radius(r: float) -> void:
		radius = r
		queue_redraw()
	func _set_alpha(a: float) -> void:
		alpha = a
		queue_redraw()
	func _draw() -> void:
		if draw_fn.is_valid():
			draw_fn.call(radius, alpha)
