extends Node
## GameManager (autoload singleton)
## Holds global run state: gold, lives, current wave. Emits signals the HUD/world react to.

signal gold_changed(amount: int)
signal lives_changed(lives: int)
signal wave_changed(wave_index: int, total_waves: int)
signal wave_bonus_awarded(amount: int, wave_index: int)
signal game_won
signal game_lost

const START_GOLD: int = 200
const START_LIVES: int = 20
# Bonus gold for surviving a wave, scaling with wave number so the lategame
# economy keeps pace with the tougher enemies. Without this the early game
# stagnates (wave 1 kills alone yield only ~36 gold).
const WAVE_CLEAR_BASE: int = 30
const WAVE_CLEAR_PER_WAVE: int = 12

var gold: int = START_GOLD:
	set(v):
		gold = max(0, v)
		gold_changed.emit(gold)

var lives: int = START_LIVES:
	set(v):
		lives = max(0, v)
		lives_changed.emit(lives)
		if lives <= 0:
			game_lost.emit()

var current_wave: int = 0
var total_waves: int = 0

var game_over: bool = false


func reset_run() -> void:
	gold = START_GOLD
	lives = START_LIVES
	current_wave = 0
	game_over = false


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
	game_won.emit()
