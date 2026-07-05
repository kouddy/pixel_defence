extends Node
## Save (autoload singleton)
## Persists story progression across runs: which level the player has reached.
##
## Storage: a Godot ConfigFile at user://progress.cfg. The format is versioned
## (SAVE_VERSION) so future schema changes can migrate or reset cleanly instead
## of silently corrupting.
##
## API:
##   is_level_unlocked(story_index) -> bool   # can the player enter this level?
##   beat_level(story_index)                  # record a victory; unlocks next
##   unlocked_level_index -> int              # highest unlocked (0-based)
##   reset_progress()                         # wipe save (New Game)
##
## Level 0 is always unlocked (the start of the story).

signal progress_changed(unlocked_level_index: int)

const SAVE_PATH := "user://progress.cfg"
const SAVE_SECTION := "progress"
const SAVE_VERSION := 1

# Highest story-index the player has unlocked (0-based). Level 0 is always
# playable; beating level i unlocks level i+1.
var unlocked_level_index: int = 0:
	set(v):
		unlocked_level_index = maxi(0, v)
		progress_changed.emit(unlocked_level_index)


func _ready() -> void:
	_load()


# ============================ PUBLIC API ============================

## Can the player enter the level at this story index?
func is_level_unlocked(story_index: int) -> bool:
	return story_index >= 0 and story_index <= unlocked_level_index


## Record that the player beat `story_index`. Unlocks the next level if this
## was a new frontier, then writes to disk.
func beat_level(story_index: int) -> void:
	if story_index + 1 > unlocked_level_index:
		# Only grow; never shrink (beating an earlier level is a no-op).
		unlocked_level_index = story_index + 1
		_save()


## Wipe all progress (used by a "New Game" affordance on the menu).
func reset_progress() -> void:
	unlocked_level_index = 0
	_save()


# ============================ DISK I/O ============================

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(SAVE_SECTION, "version", SAVE_VERSION)
	cfg.set_value(SAVE_SECTION, "unlocked_level_index", unlocked_level_index)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		push_warning("Save: failed to write progress (%d)" % err)


func _load() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		# No save yet (first launch) — defaults stand.
		return
	var version: int = cfg.get_value(SAVE_SECTION, "version", 0)
	if version != SAVE_VERSION:
		# Schema mismatch: reset rather than risk a corrupted interpretation.
		push_warning("Save: version %d != %d; resetting progress" % [version, SAVE_VERSION])
		reset_progress()
		return
	unlocked_level_index = cfg.get_value(SAVE_SECTION, "unlocked_level_index", 0)
