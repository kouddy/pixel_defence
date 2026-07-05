extends Control
## MainMenu: the title screen + level select. Shown on launch and whenever the
## player quits back to menu from a run.
##
## Builds one button per level in story order (Levels.STORY_ORDER). Locked
## levels (those past Save.unlocked_level_index) are disabled and show a lock
## hint. Each card also lists what the level unlocks (tower + the new enemy it
## introduces), so the story progression reads at a glance.

const LevelsDB := preload("res://src/data/levels.gd")

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var level_list: VBoxContainer = %LevelList
@onready var reset_btn: Button = %ResetProgressButton


func _ready() -> void:
	# Title screen runs in real time regardless of any leftover pause state.
	Engine.time_scale = 1.0
	get_tree().paused = false
	_build_level_buttons()
	reset_btn.pressed.connect(_on_reset_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		SFX.set_muted(not SFX.is_muted())


## Build one card per story level. Locked levels (index > Save.unlocked_level_index)
## are disabled and labeled with the unlock requirement.
func _build_level_buttons() -> void:
	for child in level_list.get_children():
		child.queue_free()
	for i in LevelsDB.STORY_ORDER.size():
		var def = LevelsDB.STORY_ORDER[i]
		var unlocked: bool = Save.is_level_unlocked(i)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(560, 96)
		btn.add_theme_font_size_override("font_size", 17)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		var unlocked_line := _unlock_line(def)
		if unlocked:
			btn.text = "%d. %s\n%s\n%s" % [i + 1, def[&"display_name"],
				def.get(&"description", ""), unlocked_line]
			btn.tooltip_text = _tooltip(def, i)
			btn.pressed.connect(func(): _start_level(def))
		else:
			# Locked: name + the requirement. Disabled.
			var prev_name: String = LevelsDB.STORY_ORDER[maxi(0, i - 1)][&"display_name"]
			btn.text = "🔒  %d. %s\n   Locked — beat \"%s\" to unlock" % [i + 1, def[&"display_name"], prev_name]
			btn.tooltip_text = "%s\nUnlocks after you defeat %s." % [def[&"display_name"], prev_name]
			btn.disabled = true
			btn.modulate = Color(1, 1, 1, 0.5)
		level_list.add_child(btn)


## One-line summary of what the level adds to the arsenal/bestiary, for the
## story hook. e.g. "Unlocks: Crossbowman 🏹  •  New foe: Cursed Skull 💀"
func _unlock_line(def: Dictionary) -> String:
	var parts := PackedStringArray()
	var unit_ids: Array = def.get(&"unlocked_units", [])
	if not unit_ids.is_empty():
		var names := PackedStringArray()
		for uid in unit_ids:
			names.append(Units.def_for(uid)[&"display_name"])
		parts.append("Unlocks: " + ", ".join(names))
	var new_enemy := _first_new_enemy(def)
	if new_enemy != "":
		parts.append("New foe: " + new_enemy)
	if parts.is_empty():
		return "The full arsenal stands ready."
	return " • ".join(parts)


## The first enemy id in this level's waves that no earlier story level uses.
## Returns the enemy's display_name, or "" if the level introduces no new foe.
func _first_new_enemy(def: Dictionary) -> String:
	var idx: int = LevelsDB.story_index(def[&"id"])
	if idx < 0:
		return ""
	# Collect enemy ids from all earlier levels.
	var earlier: Dictionary = {}
	for i in idx:
		for w in LevelsDB.STORY_ORDER[i][&"waves"]:
			for g in w:
				earlier[g[&"enemy"]] = true
	# Find the first id in THIS level's waves not in `earlier`.
	for w in def[&"waves"]:
		for g in w:
			var eid = g[&"enemy"]
			if not earlier.has(eid):
				return Enemies.by_id(eid).display_name
	return ""


func _tooltip(def: Dictionary, idx: int) -> String:
	var gold: int = def.get(&"start_gold", 200)
	var lives: int = def.get(&"start_lives", 20)
	var waves: int = def[&"waves"].size()
	return "Start gold: %d   |   Lives: %d   |   Waves: %d" % [gold, lives, waves]


func _start_level(def: Dictionary) -> void:
	GameManager.start_run(def)


func _on_reset_pressed() -> void:
	# Two-click confirm: first click arms (label changes), second wipes + rebuilds.
	if reset_btn.has_meta(&"armed"):
		Save.reset_progress()
		reset_btn.remove_meta(&"armed")
		reset_btn.text = "↺ Reset Progress"
		_build_level_buttons()
	else:
		reset_btn.set_meta(&"armed", true)
		reset_btn.text = "⚠ Confirm: erase all progress?"
