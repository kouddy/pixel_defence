class_name Levels
## Static catalogue of playable maps.
##
## Each level defines: path waypoints (tile coords), castle footprint (the goal),
## a deterministic noise seed (drives biome decoration), starting economy, and
## its wave script (a list of waves, each wave a list of spawn groups).
##
## Wave/group format matches WaveSpawner's expectation:
##   wave  = [ group, group, ... ]
##   group = { enemy, count, interval, gap_after }
##
## Coordinates are tile (col,row) on the 32x18 grid; top-left is (0,0). Spawn is
## typically off the left edge (col -2); the castle sits at the right edge.

const GREENFIELD := {
	&"id": &"greenfield",
	&"display_name": "Crystal Valley",
	&"description": "A gentle S-curve through the heartland. The classic siege.",
	&"start_gold": 200,
	&"start_lives": 20,
	&"map_seed": 1337.0,
	# Towers introduced by this level. The full buildable arsenal on a level is
	# the union of `unlocked_units` across this level and all earlier ones —
	# see GameManager.available_unit_ids(). The base 4 towers all unlock here.
	&"unlocked_units": [&"soldier", &"archer", &"knight", &"wizard"],
	&"path_tiles": [
		Vector2i(-2, 2),
		Vector2i(6, 2),
		Vector2i(6, 8),
		Vector2i(25, 8),
		Vector2i(25, 14),
		Vector2i(13, 14),
		Vector2i(13, 11),
		Vector2i(28, 11),
		Vector2i(30, 11),
	],
	&"castle_tiles": [
		Vector2i(30, 10), Vector2i(31, 10),
		Vector2i(30, 11), Vector2i(31, 11),
	],
	&"waves": [
		# Wave 1 — gentle intro: goblins
		[{ &"enemy": &"goblin", &"count": 6, &"interval": 0.9, &"gap_after": 1.5 }],
		# Wave 2 — goblins + a couple skeletons
		[
			{ &"enemy": &"goblin", &"count": 8, &"interval": 0.7, &"gap_after": 1.2 },
			{ &"enemy": &"skeleton", &"count": 3, &"interval": 1.1, &"gap_after": 1.5 },
		],
		# Wave 3 — introduce wolves: fast ground rushers
		[
			{ &"enemy": &"goblin", &"count": 6, &"interval": 0.6, &"gap_after": 0.8 },
			{ &"enemy": &"wolf", &"count": 4, &"interval": 0.7, &"gap_after": 1.2 },
			{ &"enemy": &"skeleton", &"count": 3, &"interval": 1.0, &"gap_after": 1.5 },
		],
		# Wave 4 — introduce flyers (bats)
		[
			{ &"enemy": &"goblin", &"count": 8, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 6, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 5 — mixed pressure
		[
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.8, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 5, &"interval": 0.9, &"gap_after": 1.0 },
			{ &"enemy": &"wolf", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 6 — first troll (regen)
		[
			{ &"enemy": &"bat", &"count": 8, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"goblin", &"count": 12, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 7 — demons + wolves
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
	],
}

const SHADOWFEN := {
	&"id": &"shadowfen",
	&"display_name": "Shadowfen",
	&"description": "A swampland zigzag. flyers and trolls come early — bring archers.",
	&"start_gold": 190,
	&"start_lives": 18,
	&"map_seed": 4242.0,
	# Unlocks the Crossbowman (introduces the Cursed Skull enemy in its waves).
	&"unlocked_units": [&"crossbowman"],
	# Tighter vertical zigzag: top run -> drop -> mid run -> rise -> exit.
	# More corners = more retargeting, harder to cover with one tower.
	&"path_tiles": [
		Vector2i(-2, 3),
		Vector2i(10, 3),
		Vector2i(10, 13),
		Vector2i(20, 13),
		Vector2i(20, 4),
		Vector2i(28, 4),
		Vector2i(28, 11),
		Vector2i(30, 11),
	],
	&"castle_tiles": [
		Vector2i(30, 10), Vector2i(31, 10),
		Vector2i(30, 11), Vector2i(31, 11),
	],
	&"waves": [
		# Wave 1 — bats immediately: archers required from the start
		[
			{ &"enemy": &"goblin", &"count": 5, &"interval": 0.8, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 4, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 2 — wolves early
		[
			{ &"enemy": &"wolf", &"count": 5, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"goblin", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 3 — skeletons + bats; first Cursed Skulls appear
		[
			{ &"enemy": &"skeleton", &"count": 4, &"interval": 0.7, &"gap_after": 0.8 },
			{ &"enemy": &"cursed_skull", &"count": 2, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"bat", &"count": 5, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 4 — ghost swarm
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"wolf", &"count": 5, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 5 — first troll + demons
		[
			{ &"enemy": &"demon", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 10, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 6 — wolves + skeletons pressure (cursed skulls tank the front)
		[
			{ &"enemy": &"wolf", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 4, &"interval": 0.8, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 6, &"interval": 0.6, &"gap_after": 2.0 },
		],
		# Wave 7 — twin trolls
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.5, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 12, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained mixed assault (cursed skulls replace skeletons)
		[
			{ &"enemy": &"ghost", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"wolf", &"count": 8, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.2, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + heavy escort
		[
			{ &"enemy": &"bat", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 1.0, &"gap_after": 1.5 },
			{ &"enemy": &"wolf", &"count": 10, &"interval": 0.3, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const DRAGONS_REACH := {
	&"id": &"dragons_reach",
	&"display_name": "Dragon's Reach",
	&"description": "A long winding approach to the dragon's lair. Hardest ramp of the early arc.",
	&"start_gold": 280,
	&"start_lives": 18,
	&"map_seed": 9001.0,
	# Unlocks the Frost Mage (introduces the Wraith enemy in its waves).
	&"unlocked_units": [&"frost_mage"],
	# Long serpentine: four switchbacks give towers many flanks but enemies a
	# long route, so a single leak hurts more (fewer lives to spare).
	&"path_tiles": [
		Vector2i(-2, 2),
		Vector2i(4, 2),
		Vector2i(4, 8),
		Vector2i(13, 8),
		Vector2i(13, 2),
		Vector2i(22, 2),
		Vector2i(22, 15),
		Vector2i(28, 15),
		Vector2i(28, 9),
		Vector2i(30, 9),
	],
	&"castle_tiles": [
		Vector2i(30, 8), Vector2i(31, 8),
		Vector2i(30, 9), Vector2i(31, 9),
	],
	&"waves": [
		# Wave 1 — opener: goblins then a small wolf dash. Tougher than other
		# levels' wave 1, but not a wall.
		[
			{ &"enemy": &"goblin", &"count": 8, &"interval": 0.7, &"gap_after": 1.2 },
			{ &"enemy": &"wolf", &"count": 3, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 2 — armored + a few flyers; first Wraiths appear
		[
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.7, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 3, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 3 — speed + ghosts
		[
			{ &"enemy": &"wolf", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 6, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 4 — first demon + skeletons (troll held back to wave 5)
		[
			{ &"enemy": &"demon", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"skeleton", &"count": 8, &"interval": 0.5, &"gap_after": 1.5 },
			{ &"enemy": &"wraith", &"count": 5, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 5 — first troll + air support (wraiths replace bats)
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 6 — trolls + wolves
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.5, &"gap_after": 1.0 },
			{ &"enemy": &"wolf", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 2, &"interval": 1.2, &"gap_after": 2.0 },
		],
		# Wave 7 — demon pack + chaff (wraiths keep anti-air honest)
		[
			{ &"enemy": &"demon", &"count": 5, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"skeleton", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained mixed assault (the gauntlet before the boss)
		[
			{ &"enemy": &"ghost", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"wolf", &"count": 8, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: the dragon + heavy escort. One dragon so a perfect
		# defence can still no-leak the finale.
		[
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 1.2 },
			{ &"enemy": &"wolf", &"count": 8, &"interval": 0.35, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const PLAGUELANDS := {
	&"id": &"plaguelands",
	&"display_name": "Plaguelands",
	&"description": "A ruined temple march. Hellhounds hunt in burning packs.",
	&"start_gold": 280,
	&"start_lives": 18,
	&"map_seed": 7331.0,
	# Unlocks the Catapult (introduces Hellhounds in its waves).
	&"unlocked_units": [&"catapult"],
	# Two parallel vertical runs joined by a long middle horizontal — gives the
	# Catapult's long range room to shine across the central lane.
	&"path_tiles": [
		Vector2i(-2, 4),
		Vector2i(8, 4),
		Vector2i(8, 14),
		Vector2i(24, 14),
		Vector2i(24, 3),
		Vector2i(28, 3),
		Vector2i(28, 11),
		Vector2i(30, 11),
	],
	&"castle_tiles": [
		Vector2i(30, 10), Vector2i(31, 10),
		Vector2i(30, 11), Vector2i(31, 11),
	],
	&"waves": [
		# Wave 1 — cursed skulls + wolves: armored from the start (Catapult helps)
		[
			{ &"enemy": &"cursed_skull", &"count": 4, &"interval": 0.9, &"gap_after": 1.0 },
			{ &"enemy": &"wolf", &"count": 5, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 2 — wraiths + skeletons (mixed air/ground)
		[
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 3 — first hellhounds: very fast + armored
		[
			{ &"enemy": &"hellhound", &"count": 4, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"goblin", &"count": 10, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 4 — trolls + cursed skulls (heavy frontline)
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
			{ &"enemy": &"wraith", &"count": 5, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 5 — hellhound pack
		[
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"wolf", &"count": 8, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 8, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 6 — twin trolls + demons
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.4, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 8, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 7 — demon + hellhound combo (armored + fast)
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained siege
		[
			{ &"enemy": &"ghost", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + hellhound escort
		[
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const SUNKEN_CRYPT := {
	&"id": &"sunken_crypt",
	&"display_name": "Sunken Crypt",
	&"description": "Drowned catacombs. Banshees wail through the maze of causeways.",
	&"start_gold": 300,
	&"start_lives": 16,
	&"map_seed": 5555.0,
	# Unlocks the Vampire. (Banshees introduced in its waves.)
	# NOTE: the Vampire tower is a planned future tower; until added, this level
	# just doesn't unlock a new tower — the player's existing 6-tower arsenal
	# carries over. Set to empty so no missing-id button renders.
	&"unlocked_units": [],
	# Maze-like: three short horizontal runs linked by long verticals — many
	# corners, so towers rarely get long sightlines. Punishes poor placement.
	&"path_tiles": [
		Vector2i(-2, 2),
		Vector2i(3, 2),
		Vector2i(3, 15),
		Vector2i(15, 15),
		Vector2i(15, 4),
		Vector2i(22, 4),
		Vector2i(22, 15),
		Vector2i(28, 15),
		Vector2i(28, 9),
		Vector2i(30, 9),
	],
	&"castle_tiles": [
		Vector2i(30, 8), Vector2i(31, 8),
		Vector2i(30, 9), Vector2i(31, 9),
	],
	&"waves": [
		# Wave 1 — wraiths + skeletons
		[
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 2 — hellhounds + cursed skulls
		[
			{ &"enemy": &"hellhound", &"count": 5, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 5, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 3 — first banshees: HP sponges
		[
			{ &"enemy": &"banshee", &"count": 4, &"interval": 0.8, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 4 — trolls + banshees
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"banshee", &"count": 5, &"interval": 0.7, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 5 — demon + hellhound pressure
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 6 — banshee swarm + troll
		[
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.4, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 7 — heavy mixed
		[
			{ &"enemy": &"demon", &"count": 5, &"interval": 0.9, &"gap_after": 0.8 },
			{ &"enemy": &"banshee", &"count": 6, &"interval": 0.6, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 8 — the gauntlet
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.3, &"gap_after": 0.6 },
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.8, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + banshee/wraith escort
		[
			{ &"enemy": &"banshee", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const THRONE_OF_ASH := {
	&"id": &"throne_of_ash",
	&"display_name": "Throne of Ash",
	&"description": "The dragon lord's lair. The Hydra waits at the end of all things.",
	&"start_gold": 320,
	&"start_lives": 18,
	&"map_seed": 9999.0,
	# Finale: no new tower — the full arsenal earned across the arc is brought
	# to bear. Introduces the Hydra boss.
	&"unlocked_units": [],
	# Long sweeping approach with two big switchbacks — the longest path in the
	# game, giving maximum flank opportunity but also maximum exposure.
	&"path_tiles": [
		Vector2i(-2, 3),
		Vector2i(6, 3),
		Vector2i(6, 14),
		Vector2i(14, 14),
		Vector2i(14, 3),
		Vector2i(20, 3),
		Vector2i(20, 14),
		Vector2i(27, 14),
		Vector2i(27, 8),
		Vector2i(30, 8),
	],
	&"castle_tiles": [
		Vector2i(30, 7), Vector2i(31, 7),
		Vector2i(30, 8), Vector2i(31, 8),
	],
	&"waves": [
		# Wave 1 — hellhounds + cursed skulls: a real opener
		[
			{ &"enemy": &"hellhound", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 2 — wraiths + banshees
		[
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"banshee", &"count": 5, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 3 — trolls + demons
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.3, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
		],
		# Wave 4 — heavy air (wraiths + bats)
		[
			{ &"enemy": &"wraith", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"bat", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 5 — troll + banshee + hellhound
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 0.8 },
			{ &"enemy": &"banshee", &"count": 6, &"interval": 0.5, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 6 — demon pack + cursed skulls
		[
			{ &"enemy": &"demon", &"count": 6, &"interval": 0.8, &"gap_after": 0.8 },
			{ &"enemy": &"cursed_skull", &"count": 10, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 7 — triple troll + banshees
		[
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.45, &"gap_after": 1.0 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 8 — Dragon (mini-boss) + everything
		[
			{ &"enemy": &"wraith", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 5, &"interval": 0.7, &"gap_after": 1.0 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
		# Wave 9 — FINAL BOSS: the Hydra + full escort
		[
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 5, &"interval": 0.8, &"gap_after": 1.5 },
			{ &"enemy": &"hydra", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const ALL := [GREENFIELD, SHADOWFEN, DRAGONS_REACH, PLAGUELANDS, SUNKEN_CRYPT, THRONE_OF_ASH]

# Story order = ALL today (levels are already authored in progression order).
# Kept as a separate constant so the menu and save system reference story order
# explicitly, even if ALL is later reordered or extended with bonus levels.
const STORY_ORDER := [GREENFIELD, SHADOWFEN, DRAGONS_REACH, PLAGUELANDS, SUNKEN_CRYPT, THRONE_OF_ASH]


static func by_id(level_id: StringName) -> Dictionary:
	for def in ALL:
		if def[&"id"] == level_id:
			return def
	push_error("Unknown level id: %s" % level_id)
	return GREENFIELD


## Index of a level in STORY_ORDER (0-based). -1 if not found.
static func story_index(level_id: StringName) -> int:
	for i in STORY_ORDER.size():
		if STORY_ORDER[i][&"id"] == level_id:
			return i
	return -1
