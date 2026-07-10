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

const CURSED_ABBEY := {
	&"id": &"cursed_abbey",
	&"display_name": "Cursed Abbey",
	&"description": "A cloister of the restless dead. Vampires and zombies walk the hallowed halls.",
	&"start_gold": 320,
	&"start_lives": 18,
	&"map_seed": 7070.0,
	# Unlocks the Cleric (introduces Vampires + Zombies in its waves).
	&"unlocked_units": [&"cleric"],
	# Cloister march: two long horizontals linked by short verticals — the
	# Cleric's wide dazzle covers the straight runs where undead cluster.
	&"path_tiles": [
		Vector2i(-2, 3),
		Vector2i(11, 3),
		Vector2i(11, 9),
		Vector2i(3, 9),
		Vector2i(3, 14),
		Vector2i(22, 14),
		Vector2i(22, 6),
		Vector2i(28, 6),
		Vector2i(28, 11),
		Vector2i(30, 11),
	],
	&"castle_tiles": [
		Vector2i(30, 10), Vector2i(31, 10),
		Vector2i(30, 11), Vector2i(31, 11),
	],
	&"waves": [
		# Wave 1 — zombies: slow but durable walls
		[
			{ &"enemy": &"zombie", &"count": 6, &"interval": 0.9, &"gap_after": 1.5 },
		],
		# Wave 2 — skeletons + a vampire: first regen
		[
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"vampire", &"count": 2, &"interval": 1.0, &"gap_after": 1.5 },
		],
		# Wave 3 — cursed skulls + zombies (armored + spongey)
		[
			{ &"enemy": &"cursed_skull", &"count": 4, &"interval": 0.7, &"gap_after": 0.8 },
			{ &"enemy": &"zombie", &"count": 8, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 4 — vampire pack: regen punishes chip damage
		[
			{ &"enemy": &"vampire", &"count": 6, &"interval": 0.6, &"gap_after": 1.0 },
			{ &"enemy": &"ghost", &"count": 6, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 5 — troll + zombies (regen x2)
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"zombie", &"count": 12, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"vampire", &"count": 4, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 6 — demons + vampires
		[
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"vampire", &"count": 8, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 7 — wraiths + zombies (air + ground pressure)
		[
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"zombie", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"vampire", &"count": 6, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained undead assault
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.35, &"gap_after": 0.6 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.3, &"gap_after": 0.8 },
			{ &"enemy": &"vampire", &"count": 8, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 3, &"interval": 1.0, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + vampire escort
		[
			{ &"enemy": &"vampire", &"count": 10, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.2 },
			{ &"enemy": &"zombie", &"count": 12, &"interval": 0.3, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const SANDSTORM_VAULTS := {
	&"id": &"sandstorm_vaults",
	&"display_name": "Sandstorm Vaults",
	&"description": "Sealed desert tombs. Mummies trudge through the wind and sand.",
	&"start_gold": 340,
	&"start_lives": 18,
	&"map_seed": 8181.0,
	# Unlocks the Paladin (introduces Mummies in its waves).
	&"unlocked_units": [&"paladin"],
	# Long diagonal-feeling march: a wide U that exposes enemies on both the top
	# and bottom edges — the Paladin's deep slow shines on the long straight runs.
	&"path_tiles": [
		Vector2i(-2, 2),
		Vector2i(13, 2),
		Vector2i(13, 15),
		Vector2i(4, 15),
		Vector2i(4, 8),
		Vector2i(20, 8),
		Vector2i(20, 13),
		Vector2i(28, 13),
		Vector2i(28, 9),
		Vector2i(30, 9),
	],
	&"castle_tiles": [
		Vector2i(30, 8), Vector2i(31, 8),
		Vector2i(30, 9), Vector2i(31, 9),
	],
	&"waves": [
		# Wave 1 — mummies: heavy armor from the start
		[
			{ &"enemy": &"mummy", &"count": 4, &"interval": 1.0, &"gap_after": 1.5 },
			{ &"enemy": &"skeleton", &"count": 5, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 2 — zombies + mummies (wall + wall)
		[
			{ &"enemy": &"zombie", &"count": 8, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"mummy", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
		],
		# Wave 3 — vampires + cursed skulls (regen + armor)
		[
			{ &"enemy": &"vampire", &"count": 5, &"interval": 0.6, &"gap_after": 0.8 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 4 — hellhounds: fast + armored, slip past the mummy wall
		[
			{ &"enemy": &"hellhound", &"count": 6, &"interval": 0.5, &"gap_after": 0.8 },
			{ &"enemy": &"mummy", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 5 — troll + mummies (armored regen + armored wall)
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"mummy", &"count": 8, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"vampire", &"count": 5, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 6 — demons + mummies (heavy frontline)
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 0.8 },
			{ &"enemy": &"mummy", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 7 — wraiths + mummies (air + ground)
		[
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"mummy", &"count": 8, &"interval": 0.5, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained siege
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.35, &"gap_after": 0.6 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 0.8 },
			{ &"enemy": &"mummy", &"count": 10, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + mummy escort
		[
			{ &"enemy": &"mummy", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"vampire", &"count": 8, &"interval": 0.4, &"gap_after": 1.2 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const WAR_CAMP := {
	&"id": &"war_camp",
	&"display_name": "War Camp",
	&"description": "The orc siege lines. Discipline and armor march on the castle.",
	&"start_gold": 360,
	&"start_lives": 17,
	&"map_seed": 9292.0,
	# Unlocks the Bard (introduces Orcs in its waves).
	&"unlocked_units": [&"bard"],
	# Siege approach: a long top run feeding a staggered descent — the Bard's
	# wide slow paints the long lane and clusters the orcs at the corners.
	&"path_tiles": [
		Vector2i(-2, 4),
		Vector2i(16, 4),
		Vector2i(16, 10),
		Vector2i(7, 10),
		Vector2i(7, 14),
		Vector2i(23, 14),
		Vector2i(23, 7),
		Vector2i(28, 7),
		Vector2i(28, 11),
		Vector2i(30, 11),
	],
	&"castle_tiles": [
		Vector2i(30, 10), Vector2i(31, 10),
		Vector2i(30, 11), Vector2i(31, 11),
	],
	&"waves": [
		# Wave 1 — orcs: armored infantry
		[
			{ &"enemy": &"orc", &"count": 6, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 2 — orcs + zombies (armored + sponge)
		[
			{ &"enemy": &"orc", &"count": 6, &"interval": 0.5, &"gap_after": 1.0 },
			{ &"enemy": &"zombie", &"count": 8, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 3 — hellhounds + orcs (fast + steady)
		[
			{ &"enemy": &"hellhound", &"count": 6, &"interval": 0.45, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 4 — mummies + orcs (double armor)
		[
			{ &"enemy": &"mummy", &"count": 5, &"interval": 0.7, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 10, &"interval": 0.35, &"gap_after": 1.5 },
		],
		# Wave 5 — trolls + orcs (regen + armor)
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.3, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 12, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"cursed_skull", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 6 — demons + orcs (heavy armored push)
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 12, &"interval": 0.35, &"gap_after": 1.0 },
			{ &"enemy": &"mummy", &"count": 6, &"interval": 0.5, &"gap_after": 2.0 },
		],
		# Wave 7 — wraiths + orcs (air + ground)
		[
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained assault
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.3, &"gap_after": 0.6 },
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + orc warband
		[
			{ &"enemy": &"orc", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.0 },
			{ &"enemy": &"mummy", &"count": 8, &"interval": 0.5, &"gap_after": 1.2 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const WITCHWOOD := {
	&"id": &"witchwood",
	&"display_name": "Witchwood",
	&"description": "A hexed forest where witches ride the canopy. Anti-air is mandatory.",
	&"start_gold": 380,
	&"start_lives": 16,
	&"map_seed": 3434.0,
	# Unlocks the Alchemist (introduces Witches in its waves).
	&"unlocked_units": [&"alchemist"],
	# Winding forest path: many short segments and corners — the Alchemist's
	# lobbed flasks arc over the front line to hit clustered witches.
	&"path_tiles": [
		Vector2i(-2, 2),
		Vector2i(5, 2),
		Vector2i(5, 8),
		Vector2i(12, 8),
		Vector2i(12, 3),
		Vector2i(19, 3),
		Vector2i(19, 14),
		Vector2i(26, 14),
		Vector2i(26, 9),
		Vector2i(30, 9),
	],
	&"castle_tiles": [
		Vector2i(30, 8), Vector2i(31, 8),
		Vector2i(30, 9), Vector2i(31, 9),
	],
	&"waves": [
		# Wave 1 — witches immediately: air from the start
		[
			{ &"enemy": &"witch", &"count": 6, &"interval": 0.7, &"gap_after": 1.5 },
		],
		# Wave 2 — witches + skeletons (air + ground)
		[
			{ &"enemy": &"witch", &"count": 6, &"interval": 0.6, &"gap_after": 0.8 },
			{ &"enemy": &"skeleton", &"count": 8, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 3 — wraiths + witches (double air)
		[
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"witch", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 4 — vampires + witches (regen + air)
		[
			{ &"enemy": &"vampire", &"count": 6, &"interval": 0.5, &"gap_after": 0.8 },
			{ &"enemy": &"witch", &"count": 10, &"interval": 0.35, &"gap_after": 1.5 },
		],
		# Wave 5 — troll + witch swarm
		[
			{ &"enemy": &"troll", &"count": 1, &"interval": 1.0, &"gap_after": 1.0 },
			{ &"enemy": &"witch", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 6 — demons + witches (air cover for tanks)
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 0.8 },
			{ &"enemy": &"witch", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"orc", &"count": 8, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 7 — heavy air (witches + wraiths + bats)
		[
			{ &"enemy": &"witch", &"count": 12, &"interval": 0.3, &"gap_after": 0.6 },
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.3, &"gap_after": 0.6 },
			{ &"enemy": &"bat", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained mixed assault
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.3, &"gap_after": 0.6 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 0.6 },
			{ &"enemy": &"witch", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + witch coven
		[
			{ &"enemy": &"witch", &"count": 14, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const STONE_KEEP := {
	&"id": &"stone_keep",
	&"display_name": "Stone Keep",
	&"description": "A ruined roost of living statue. Gargoyles circle the battlements.",
	&"start_gold": 400,
	&"start_lives": 16,
	&"map_seed": 5656.0,
	# Unlocks the Prince (introduces Gargoyles in its waves).
	&"unlocked_units": [&"prince"],
	# Keep circuit: a wide loop around a central block — long sightlines suit
	# the Prince's accurate single shots against the heavy flying gargoyles.
	&"path_tiles": [
		Vector2i(-2, 3),
		Vector2i(8, 3),
		Vector2i(8, 15),
		Vector2i(24, 15),
		Vector2i(24, 3),
		Vector2i(20, 3),
		Vector2i(20, 11),
		Vector2i(12, 11),
		Vector2i(12, 8),
		Vector2i(30, 8),
	],
	&"castle_tiles": [
		Vector2i(30, 7), Vector2i(31, 7),
		Vector2i(30, 8), Vector2i(31, 8),
	],
	&"waves": [
		# Wave 1 — gargoyles: heavy armored air from the start
		[
			{ &"enemy": &"gargoyle", &"count": 4, &"interval": 1.0, &"gap_after": 1.5 },
			{ &"enemy": &"skeleton", &"count": 6, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 2 — gargoyles + witches (heavy + light air)
		[
			{ &"enemy": &"gargoyle", &"count": 5, &"interval": 0.8, &"gap_after": 0.8 },
			{ &"enemy": &"witch", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 3 — mummies + gargoyles (armored ground + air)
		[
			{ &"enemy": &"mummy", &"count": 6, &"interval": 0.6, &"gap_after": 0.8 },
			{ &"enemy": &"gargoyle", &"count": 6, &"interval": 0.6, &"gap_after": 1.5 },
		],
		# Wave 4 — hellhounds + gargoyles (fast ground + heavy air)
		[
			{ &"enemy": &"hellhound", &"count": 8, &"interval": 0.4, &"gap_after": 0.6 },
			{ &"enemy": &"gargoyle", &"count": 8, &"interval": 0.5, &"gap_after": 1.5 },
		],
		# Wave 5 — troll + gargoyle roost
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.3, &"gap_after": 0.8 },
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.4, &"gap_after": 1.0 },
			{ &"enemy": &"witch", &"count": 8, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 6 — demons + gargoyles (armored everything)
		[
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 0.6 },
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 10, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 7 — banshees + gargoyles (sponge + heavy air)
		[
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.5, &"gap_after": 0.6 },
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"wraith", &"count": 8, &"interval": 0.35, &"gap_after": 2.0 },
		],
		# Wave 8 — sustained stone + undead assault
		[
			{ &"enemy": &"ghost", &"count": 10, &"interval": 0.3, &"gap_after": 0.5 },
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.0, &"gap_after": 0.6 },
			{ &"enemy": &"gargoyle", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 2.0 },
		],
		# Wave 9 — BOSS: Dragon + gargoyle escort
		[
			{ &"enemy": &"gargoyle", &"count": 12, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"witch", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
			{ &"enemy": &"dragon", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const GATES_OF_THE_ABYSS := {
	&"id": &"gates_of_the_abyss",
	&"display_name": "Gates of the Abyss",
	&"description": "The Demon Lord's threshold. Every horror of the realm converges here.",
	&"start_gold": 420,
	&"start_lives": 18,
	&"map_seed": 1313.0,
	# Finale of the extended arc: unlocks the Princess. Introduces the Demon Lord
	# boss. The full arsenal earned across both arcs is brought to bear.
	&"unlocked_units": [&"princess"],
	# The longest, most exposed path: a grand sweep with two big switchbacks,
	# giving maximum flank opportunity against the final assault.
	&"path_tiles": [
		Vector2i(-2, 3),
		Vector2i(5, 3),
		Vector2i(5, 14),
		Vector2i(13, 14),
		Vector2i(13, 3),
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
		# Wave 1 — gargoyles + orcs: a real opener
		[
			{ &"enemy": &"gargoyle", &"count": 6, &"interval": 0.5, &"gap_after": 0.8 },
			{ &"enemy": &"orc", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 2 — vampires + witches (regen + air)
		[
			{ &"enemy": &"vampire", &"count": 8, &"interval": 0.4, &"gap_after": 0.8 },
			{ &"enemy": &"witch", &"count": 8, &"interval": 0.4, &"gap_after": 1.5 },
		],
		# Wave 3 — trolls + demons (heavy frontline)
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.3, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 4, &"interval": 0.9, &"gap_after": 1.5 },
		],
		# Wave 4 — heavy air (gargoyles + wraiths)
		[
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.35, &"gap_after": 0.8 },
			{ &"enemy": &"wraith", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 5 — troll + mummy + hellhound (armor + regen + speed)
		[
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 0.6 },
			{ &"enemy": &"mummy", &"count": 8, &"interval": 0.4, &"gap_after": 0.6 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 6 — demon pack + vampires
		[
			{ &"enemy": &"demon", &"count": 6, &"interval": 0.8, &"gap_after": 0.6 },
			{ &"enemy": &"vampire", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"gargoyle", &"count": 8, &"interval": 0.4, &"gap_after": 2.0 },
		],
		# Wave 7 — banshees + gargoyles + witches (air dominance)
		[
			{ &"enemy": &"banshee", &"count": 8, &"interval": 0.45, &"gap_after": 0.6 },
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.35, &"gap_after": 0.6 },
			{ &"enemy": &"witch", &"count": 10, &"interval": 0.3, &"gap_after": 2.0 },
		],
		# Wave 8 — Hydra (arc-1 boss) + everything
		[
			{ &"enemy": &"wraith", &"count": 12, &"interval": 0.3, &"gap_after": 0.8 },
			{ &"enemy": &"troll", &"count": 3, &"interval": 1.0, &"gap_after": 0.8 },
			{ &"enemy": &"demon", &"count": 5, &"interval": 0.7, &"gap_after": 1.0 },
			{ &"enemy": &"hydra", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
		# Wave 9 — FINAL BOSS: the Demon Lord + full escort
		[
			{ &"enemy": &"gargoyle", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"hellhound", &"count": 10, &"interval": 0.3, &"gap_after": 1.0 },
			{ &"enemy": &"troll", &"count": 2, &"interval": 1.2, &"gap_after": 1.2 },
			{ &"enemy": &"demon", &"count": 5, &"interval": 0.8, &"gap_after": 1.5 },
			{ &"enemy": &"demon_lord", &"count": 1, &"interval": 1.0, &"gap_after": 2.0 },
		],
	],
}

const ALL := [GREENFIELD, SHADOWFEN, DRAGONS_REACH, PLAGUELANDS, SUNKEN_CRYPT, THRONE_OF_ASH,
	CURSED_ABBEY, SANDSTORM_VAULTS, WAR_CAMP, WITCHWOOD, STONE_KEEP, GATES_OF_THE_ABYSS]

# Story order = ALL today (levels are already authored in progression order).
# Kept as a separate constant so the menu and save system reference story order
# explicitly, even if ALL is later reordered or extended with bonus levels.
const STORY_ORDER := [GREENFIELD, SHADOWFEN, DRAGONS_REACH, PLAGUELANDS, SUNKEN_CRYPT, THRONE_OF_ASH,
	CURSED_ABBEY, SANDSTORM_VAULTS, WAR_CAMP, WITCHWOOD, STONE_KEEP, GATES_OF_THE_ABYSS]


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
