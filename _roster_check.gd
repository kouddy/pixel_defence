extends Node

func _ready() -> void:
	print("=== Units.ALL (full roster) ===")
	for def in Units.ALL:
		print("  ", def[&"id"])
	print("  paladin falls back? ", Units.def_for(&"paladin").id == &"soldier")
	print("  alchemist falls back? ", Units.def_for(&"alchemist").id == &"soldier")

	print("\n=== Level unlock reassignment ===")
	for lvl in LevelsDB.STORY_ORDER:
		var u = lvl.get(&"unlocked_units", [])
		print("  ", lvl[&"id"], " unlocks: ", u)

	print("\n=== Cumulative arsenal at level 12 ===")
	GameManager.selected_level = LevelsDB.GATES_OF_THE_ABYSS
	var ids = GameManager.available_unit_ids()
	print("  ", ids)
	print("  paladin absent? ", not ids.has(&"paladin"))
	print("  alchemist absent? ", not ids.has(&"alchemist"))
	print("  prince present? ", ids.has(&"prince"))
	print("  bard present? ", ids.has(&"bard"))
	get_tree().quit()
