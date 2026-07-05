extends Node
## WaveSpawner: spawns enemies in predefined waves. Each entry is a list of
## (enemy_id, count, interval) groups. Emits signals the main scene listens to.
##
## The wave script is supplied per-level via configure() (see Levels.gd).

signal wave_started(index: int, total: int)
signal wave_cleared(index: int)
signal all_waves_cleared

@export var world_path: NodePath = ^""
@export var enemy_scene: PackedScene = preload("res://src/enemies/enemy.tscn")

# Each wave is a list of spawn groups: { enemy, count, interval, gap_after }
var _waves: Array = []
var _wave_index: int = -1
var _active_enemies: int = 0
var _running: bool = false


func _ready() -> void:
	# Pull the wave script from the selected level. Done in _ready (not _init)
	# so the autoload is guaranteed to be set before we read it.
	configure(GameManager.selected_level)


## Load the wave script for a level. Resets spawner state so a fresh run starts
## cleanly (used by run-restart).
func configure(level: Dictionary) -> void:
	_waves = level.get(&"waves", [])
	_wave_index = -1
	_active_enemies = 0
	_running = false


func get_total_waves() -> int:
	return _waves.size()


## Sum each enemy type's count across all groups in a wave.
## `wave_index` is 0-based. Returns Dictionary[StringName, int].
func get_wave_composition(wave_index: int) -> Dictionary:
	var comp: Dictionary = {}
	if wave_index < 0 or wave_index >= _waves.size():
		return comp
	for group in _waves[wave_index]:
		var id = group[&"enemy"]
		comp[id] = comp.get(id, 0) + int(group[&"count"])
	return comp


func start_next_wave() -> void:
	if _running:
		return
	_wave_index += 1
	if _wave_index >= _waves.size():
		all_waves_cleared.emit()
		return
	_running = true
	wave_started.emit(_wave_index + 1, _waves.size())
	GameManager.start_wave(_wave_index + 1, _waves.size())
	SFX.wave_start()
	_run_wave(_waves[_wave_index])


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
