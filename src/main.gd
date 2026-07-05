extends Node2D
## Main: root gameplay scene. Owns the world, wave spawner, HUD.
## Handles build-mode interaction: select a unit from the build bar, then click
## a valid tile to place a tower there.

const TOWER_SCENE := preload("res://src/towers/tower.tscn")

@onready var world: Node2D = $GameWorld
@onready var hud: Control = $HUD
@onready var spawner: Node = $WaveSpawner
@onready var towers_node: Node2D = $Towers

var _build_data: UnitData = null
var _enemies: Array = []
var _selected_tower: Node2D = null   # currently-selected placed tower (for upgrade UI)
var _wave_running: bool = false      # true between wave_started and wave_cleared
var _paused: bool = false            # player-initiated pause (only during a wave)


func _ready() -> void:
	GameManager.reset_run()
	_resize_hud_to_viewport()
	get_viewport().size_changed.connect(_resize_hud_to_viewport)
	hud.build_selected.connect(_on_build_selected)
	hud.start_wave_requested.connect(_on_start_wave)
	hud.pause_requested.connect(_toggle_pause)
	hud.upgrade_requested.connect(_on_upgrade_requested)
	hud.sell_requested.connect(_on_sell_requested)
	hud.speed_changed.connect(_on_speed_changed)
	spawner.world_path = world.get_path()
	spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	spawner.wave_started.connect(_on_wave_started)
	spawner.wave_cleared.connect(_on_wave_cleared)
	hud.set_start_wave_enabled(true)
	# Show what's coming in wave 1 so the player isn't blind at the start.
	hud.show_wave_preview(1, spawner.get_total_waves(), spawner.get_wave_composition(0))


func _exit_tree() -> void:
	# Always restore real time on exit so editor/next run isn't stuck fast.
	Engine.time_scale = 1.0


## Toggle simulation speed (1x / 2x). Pausing still works on top via tree pause.
func _on_speed_changed(mult: float) -> void:
	Engine.time_scale = mult


func _process(_dt: float) -> void:
	# Refresh tower target lists each frame.
	_enemies = get_tree().get_nodes_in_group("enemies")
	for t in towers_node.get_children():
		t.set_enemies(_enemies)


func _resize_hud_to_viewport() -> void:
	# The HUD is a Control parented under a Node2D (which has no size), so its
	# anchor-based layout collapses. Force it to fill the viewport. Deferred so
	# we don't fight Godot's anchor-driven size during _ready().
	var vp := get_viewport_rect().size
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.set_deferred("size", vp)
	hud.set_deferred("position", Vector2.ZERO)
	hud.update_minimum_size()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:
				SFX.set_muted(not SFX.is_muted())
			KEY_SPACE, KEY_P:
				_toggle_pause()
			KEY_ENTER, KEY_KP_ENTER:
				# Start the next wave during the build phase (no-op mid-wave:
				# the button is disabled and _on_start_wave guards re-entry).
				if not _wave_running and not GameManager.game_over:
					_on_start_wave()
	if event is InputEventMouseMotion:
		if _build_data != null:
			var ok: bool = world.can_build_at(event.position) and GameManager.can_afford(_build_data.cost)
			world.show_build_hint(event.position, ok)
		_update_tower_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _build_data != null:
			_try_place(event.position)
		else:
			_try_select_tower(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if _build_data != null:
			_cancel_build()
		else:
			_deselect_tower()


func _update_tower_hover(mouse_pos: Vector2) -> void:
	# Show range circle when the cursor is over an existing tower, or always
	# for the currently-selected tower so its reach stays legible.
	for t in towers_node.get_children():
		var tower: Node2D = t
		var near: bool = tower.global_position.distance_to(mouse_pos) <= 28.0
		tower.show_range(near or tower == _selected_tower)


func _try_select_tower(pos: Vector2) -> void:
	# Pick the closest tower within a click radius; none -> deselect.
	var best: Node2D = null
	var best_dist := 32.0
	for t in towers_node.get_children():
		var tower: Node2D = t
		var d := tower.global_position.distance_to(pos)
		if d <= best_dist:
			best_dist = d
			best = tower
	_select_tower(best)


func _select_tower(tower: Node2D) -> void:
	if _selected_tower == tower:
		return
	if is_instance_valid(_selected_tower) and _selected_tower.has_signal("changed"):
		_selected_tower.changed.disconnect(_on_selected_tower_changed)
	_selected_tower = tower
	if is_instance_valid(tower):
		tower.show_range(true)
		if tower.has_signal("changed"):
			tower.changed.connect(_on_selected_tower_changed)
	hud.show_tower_panel(tower)


func _deselect_tower() -> void:
	_select_tower(null)


func _on_selected_tower_changed(_tower: Node2D) -> void:
	# Stats changed (upgrade) — refresh the panel content.
	hud.show_tower_panel(_selected_tower)


func _on_upgrade_requested() -> void:
	if not is_instance_valid(_selected_tower) or not _selected_tower.has_method("upgrade"):
		return
	var cost: int = _selected_tower.next_upgrade_cost()
	if cost < 0 or not GameManager.can_afford(cost):
		SFX.build_deny()
		return
	GameManager.spend(cost)
	_selected_tower.upgrade()


func _on_sell_requested() -> void:
	if not is_instance_valid(_selected_tower) or not _selected_tower.has_method("sell_value"):
		return
	var refund: int = _selected_tower.sell_value()
	GameManager.earn(refund)
	FX.flash_at(_selected_tower.global_position, Color(1.0, 0.92, 0.45), 20.0)
	FX.ring(_selected_tower.global_position, Color(1.0, 0.85, 0.35), 36.0)
	SFX.place()
	# Free the tile and remove the tower, then close the panel.
	var tile: Vector2i = world.world_to_tile(_selected_tower.global_position)
	world.occupied.erase(tile)
	var sold := _selected_tower
	_deselect_tower()
	sold.queue_free()


func _try_place(pos: Vector2) -> void:
	if not world.can_build_at(pos):
		SFX.build_deny()
		return
	if not GameManager.can_afford(_build_data.cost):
		SFX.build_deny()
		_cancel_build()
		return
	GameManager.spend(_build_data.cost)
	var tower := TOWER_SCENE.instantiate()
	towers_node.add_child(tower)
	tower.global_position = world.snapped_center(pos)
	tower.configure(_build_data.duplicate())
	world.occupy(pos)
	# Placement pop: flash + ring so building feels responsive, not silent.
	FX.flash_at(tower.global_position, _build_data.color, 18.0)
	FX.ring(tower.global_position, _build_data.color, 34.0)
	SFX.place()
	# Keep build mode active if the player still has gold for another; otherwise exit.
	if not GameManager.can_afford(_build_data.cost):
		_cancel_build()


func _on_build_selected(unit_data: UnitData) -> void:
	_build_data = unit_data
	# Entering build mode closes any open tower panel.
	_deselect_tower()


func _cancel_build() -> void:
	_build_data = null
	world.hide_build_hint()


func _on_start_wave() -> void:
	spawner.start_next_wave()


func _on_wave_started(idx: int, total: int) -> void:
	_wave_running = true
	hud.set_start_wave_enabled(false)
	hud.set_can_pause(true)
	# Preview the NEXT wave (if any) so the player can plan during this one.
	var next_idx := idx   # idx is 1-based; next wave index is also 1-based
	if next_idx < total:
		hud.show_wave_preview(next_idx + 1, total, spawner.get_wave_composition(idx))


func _on_wave_cleared(index: int) -> void:
	_wave_running = false
	# If the player had paused, make sure we unpause before the build phase.
	if _paused:
		_set_paused(false)
	hud.set_start_wave_enabled(true)
	hud.set_can_pause(false)
	# Survival bonus keeps the economy from stagnating in the early game.
	GameManager.award_wave_bonus(index)
	# Floating "+bonus" notice over the gold readout so the reward is felt.
	hud.show_wave_bonus(index, GameManager.WAVE_CLEAR_BASE + GameManager.WAVE_CLEAR_PER_WAVE * index)


func _on_all_waves_cleared() -> void:
	GameManager.win()


# ============================ PAUSE ============================

## Toggle the player pause overlay. Only allowed while a wave is running —
## there's nothing to pause during the build phase.
func _toggle_pause() -> void:
	if not _wave_running:
		return
	if GameManager.game_over:
		return
	_set_paused(not _paused)


func _set_paused(v: bool) -> void:
	_paused = v
	# Let FX know so its hitstop never fights the player's pause state.
	FX.player_paused = v
	get_tree().paused = v
	hud.show_pause_overlay(v)
	if v:
		SFX.wave_start()   # a soft blip so the pause input feels acknowledged
