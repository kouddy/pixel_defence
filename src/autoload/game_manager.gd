extends Node
## GameManager (autoload singleton)
## Holds global run state: gold, lives, current wave. Emits signals the HUD/world react to.
##
## Also tracks the currently-selected level (set by the main menu) so the world
## and wave spawner can configure themselves when the gameplay scene loads.

# Preloaded so this autoload doesn't depend on global class registration order
# (autoloads load before class_name globals are guaranteed to be available).
const LevelsDB := preload("res://src/data/levels.gd")

signal gold_changed(amount: int)
signal lives_changed(lives: int)
signal wave_changed(wave_index: int, total_waves: int)
signal wave_bonus_awarded(amount: int, wave_index: int)
signal game_won
signal game_lost

# Bonus gold for surviving a wave, scaling with wave number so the lategame
# economy keeps pace with the tougher enemies. Without this the early game
# stagnates (wave 1 kills alone yield only ~36 gold).
const WAVE_CLEAR_BASE: int = 30
const WAVE_CLEAR_PER_WAVE: int = 12

# The level the player chose on the main menu. Defaults to the first level so
# the game is still playable if loaded directly (e.g. via F5 from the editor).
var selected_level: Dictionary = LevelsDB.GREENFIELD

var gold: int = 0:
	set(v):
		gold = max(0, v)
		gold_changed.emit(gold)

var lives: int = 0:
	set(v):
		lives = max(0, v)
		lives_changed.emit(lives)
		if lives <= 0 and not game_over:
			# Set game_over BEFORE emitting so handlers (and restart_run) see the
			# terminal state immediately, and a second leak can't double-fire.
			game_over = true
			game_lost.emit()

var current_wave: int = 0
var total_waves: int = 0

var game_over: bool = false

const MAIN_SCENE := "res://src/main.tscn"
const MENU_SCENE := "res://src/ui/main_menu.tscn"


func reset_run() -> void:
	# Economy/lives come from the selected level so each map can tune its own
	# difficulty (e.g. Dragon's Reach starts richer but with fewer lives).
	var start_gold: int = selected_level.get(&"start_gold", 200)
	var start_lives: int = selected_level.get(&"start_lives", 20)
	gold = start_gold
	lives = start_lives
	current_wave = 0
	game_over = false


## Towers the player may build on the currently-selected level.
##
## The arsenal is CUMULATIVE across the story arc: a level grants the union of
## its own `unlocked_units` plus every earlier story level's unlocks. So a tower
## unlocked on level 2 stays buildable on levels 3, 4, ... — classic TD
## escalation. Returns the list of unit ids (StringName) in story order.
func available_unit_ids() -> Array:
	var idx: int = LevelsDB.story_index(selected_level[&"id"])
	if idx < 0:
		idx = 0
	var ids: Array = []
	for i in range(idx + 1):
		var level: Dictionary = LevelsDB.STORY_ORDER[i]
		var unlocked: Array = level.get(&"unlocked_units", [])
		for uid in unlocked:
			if not ids.has(uid):
				ids.append(uid)
	return ids


func can_afford(amount: int) -> bool:
	return gold >= amount


func spend(amount: int) -> bool:
	if not can_afford(amount):
		return false
	gold -= amount
	return true


func earn(amount: int) -> void:
	gold += amount


func enemy_leaked() -> void:
	if game_over:
		return
	lives -= 1


func start_wave(wave_index: int, total: int) -> void:
	current_wave = wave_index
	total_waves = total
	wave_changed.emit(wave_index, total)


## Award the survival bonus when a wave is cleared. Scales with the wave number.
func award_wave_bonus(wave_index: int) -> void:
	var bonus := WAVE_CLEAR_BASE + WAVE_CLEAR_PER_WAVE * maxi(0, wave_index)
	gold += bonus
	wave_bonus_awarded.emit(bonus, wave_index)


func win() -> void:
	if game_over:
		return
	game_over = true
	# Record story progress: beating the selected level unlocks the next one.
	# Save.beat_level is a no-op if this wasn't a new frontier.
	var idx: int = LevelsDB.story_index(selected_level[&"id"])
	if idx >= 0:
		Save.beat_level(idx)
	game_won.emit()


# ============================ SCENE NAVIGATION ============================

## Start a fresh run on the given level definition. Called from the main menu.
func start_run(level: Dictionary) -> void:
	selected_level = level
	reset_run()
	get_tree().change_scene_to_file(MAIN_SCENE)


## Restart the current level from scratch (used by the game-over overlay's
## "Play Again"). Reloads the gameplay scene so all towers/enemies reset.
func restart_run() -> void:
	reset_run()
	get_tree().change_scene_to_file(MAIN_SCENE)


## Bail to the main menu (used by the game-over overlay + pause "Quit to Menu").
func goto_menu() -> void:
	# Make sure time scale and pause state don't leak into the menu.
	Engine.time_scale = 1.0
	get_tree().paused = false
	FX.player_paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
