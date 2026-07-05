extends Node
## WaveSpawner: spawns enemies in predefined waves. Each entry is a list of
## (enemy_id, count, interval) groups. Emits signals the main scene listens to.

signal wave_started(index: int, total: int)
signal wave_cleared(index: int)
signal all_waves_cleared

@export var world_path: NodePath = ^""
@export var enemy_scene: PackedScene = preload("res://src/enemies/enemy.tscn")

# Each wave is a list of spawn groups: { enemy, count, interval, gap_after }
const WAVES := [
	# Wave 1 — gentle intro: goblins
	[{ &"enemy": &"goblin", &"count": 6, &"interval": 0.9, &"gap_after": 1.5 }],
	# Wave 2 — goblins + a couple skeletons
	[
		{ &"enemy": &"goblin", &"count": 8, &"interval": 0.7, &"gap_after": 1.2 },
		{ &"enemy": &"skeleton", &"count": 3, &"interval": 1.1, &"gap_after": 1.5 },
	],
	# Wave 3 — introduce wolves: fast ground rushers that punish slow defences
	[
		{ &"enemy": &"goblin", &"count": 6, &"interval": 0.6, &"gap_after": 0.8 },
		{ &"enemy": &"wolf", &"count": 4, &"interval": 0.7, &"gap_after": 1.2 },
		{ &"enemy": &"skeleton", &"count": 3, &"interval": 1.0, &"gap_after": 1.5 },
	],
	# Wave 4 — introduce flyers (bats): need archers/wizards
	[
		{ &"enemy": &"goblin", &"count": 8, &"interval": 0.6, &"gap_after": 1.0 },
		{ &"enemy": &"bat", &"count": 6, &"interval": 0.7, &"gap_after": 1.5 },
	],
	# Wave 5 — mixed pressure: ghosts + a wolf pack
	[
		{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.8, &"gap_after": 1.0 },
		{ &"enemy": &"ghost", &"count": 5, &"interval": 0.9, &"gap_after": 1.0 },
		{ &"enemy": &"wolf", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
	],
	# Wave 6 — first troll: regenerating tank, must be focused down
	[
		{ &"enemy": &"bat", &"count": 8, &"interval": 0.5, &"gap_after": 1.0 },
		{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
		{ &"enemy": &"goblin", &"count": 12, &"interval": 0.35, &"gap_after": 2.0 },
	],
	# Wave 7 — demons + wolves: armour and speed together
	[
		{ &"enemy": &"wolf", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
		{ &"enemy": &"demon", &"count": 3, &"interval": 1.3, &"gap_after": 1.5 },
		{ &"enemy": &"skeleton", &"count": 10, &"interval": 0.4, &"gap_after": 2.0 },
	],
	# Wave 8 — twin trolls + flyers
	[
		{ &"enemy": &"ghost", &"count": 8, &"interval": 0.6, &"gap_after": 1.0 },
		{ &"enemy": &"bat", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
		{ &"enemy": &"troll", &"count": 2, &"interval": 1.5, &"gap_after": 1.5 },
		{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 2.0 },
	],
	# Wave 9 — BOSS: Dragon + escort
	[
		{ &"enemy": &"ghost", &"count": 6, &"interval": 0.8, &"gap_after": 1.0 },
		{ &"enemy": &"wolf", &"count": 8, &"interval": 0.35, &"gap_after": 1.2 },
		{ &"enemy": &"demon", &"count": 3, &"interval": 1.2, &"gap_after": 1.5 },
		{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.5 },
		{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
	],
]

var _wave_index: int = -1
var _active_enemies: int = 0
var _running: bool = false


func get_total_waves() -> int:
	return WAVES.size()


## Sum each enemy type's count across all groups in a wave.
## `wave_index` is 0-based. Returns Dictionary[StringName, int].
func get_wave_composition(wave_index: int) -> Dictionary:
	var comp: Dictionary = {}
	if wave_index < 0 or wave_index >= WAVES.size():
		return comp
	for group in WAVES[wave_index]:
		var id = group[&"enemy"]
		comp[id] = comp.get(id, 0) + int(group[&"count"])
	return comp


func start_next_wave() -> void:
	if _running:
		return
	_wave_index += 1
	if _wave_index >= WAVES.size():
		all_waves_cleared.emit()
		return
	_running = true
	wave_started.emit(_wave_index + 1, WAVES.size())
	GameManager.start_wave(_wave_index + 1, WAVES.size())
	SFX.wave_start()
	_run_wave(WAVES[_wave_index])


func _run_wave(groups: Array) -> void:
	for group in groups:
		for i in group.count:
			_spawn(group.enemy)
			await get_tree().create_timer(group.interval).timeout
		await get_tree().create_timer(group.gap_after).timeout
	# Wait until all enemies of this wave are gone (killed or leaked).
	await _wait_until_cleared()
	_running = false
	wave_cleared.emit(_wave_index + 1)


func _wait_until_cleared() -> void:
	while _active_enemies > 0:
		await get_tree().process_frame


func _spawn(enemy_id: StringName) -> void:
	var world := get_node_or_null(world_path)
	if world == null:
		push_error("WaveSpawner: world node not found at %s" % world_path)
		return
	var e := enemy_scene.instantiate()
	world.add_child(e)
	var data := Enemies.by_id(enemy_id)
	e.configure(data, world.path_points, world.path_length())
	_active_enemies += 1
	# A wave is cleared when every spawned enemy has left the scene tree. Both
	# `_die()` and `_reach_exit()` end in `queue_free()`, and any other removal
	# (scene change, game over, etc.) also exits the tree — so `tree_exited`
	# alone is the reliable single decrement per enemy. Connecting `died` or
	# `reached_exit` as well would double-count and clear the wave too early.
	e.tree_exited.connect(_on_enemy_removed)


func _on_enemy_removed(_e: Node = null) -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
