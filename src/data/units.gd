class_name Units
## Static catalogue of buildable defender units.
## Returns fresh UnitData instances so each tower can mutate stats independently on upgrade.

const Soldier := {
	&"id": &"soldier",
	&"display_name": "Soldier",
	&"description": "Cheap melee blocker. Holds chokepoints.",
	&"color": Color(0.78, 0.55, 0.30),
	&"radius": 20,
	&"attack_type": UnitData.AttackType.MELEE,
	&"cost": 50,
	&"damage": 8.0,
	# Ranges scaled 0.8x for the narrower 16:9 grid (40 -> 32 cols) so towers
	# cover the same relative fraction of the playfield.
	&"range_px": 77.0,
	&"fire_rate": 1.5,
	&"can_hit_air": false,
}

const Archer := {
	&"id": &"archer",
	&"display_name": "Archer",
	&"description": "Ranged single-target. Hits flying enemies.",
	&"color": Color(0.45, 0.75, 0.45),
	&"radius": 20,
	&"attack_type": UnitData.AttackType.PROJECTILE,
	&"cost": 80,
	&"damage": 12.0,
	&"range_px": 160.0,
	&"fire_rate": 1.2,
	&"projectile_speed": 400.0,
	&"can_hit_air": true,
}

const Knight := {
	&"id": &"knight",
	&"display_name": "Knight",
	&"description": "Tanky frontline. Slows enemies on hit.",
	&"color": Color(0.55, 0.65, 0.85),
	&"radius": 24,
	&"attack_type": UnitData.AttackType.MELEE,
	&"cost": 110,
	&"damage": 18.0,
	&"range_px": 83.0,
	&"fire_rate": 1.0,
	&"can_hit_air": false,
	&"slows_on_hit": true,
	&"slow_factor": 0.5,
	&"slow_duration": 1.2,
}

const Wizard := {
	&"id": &"wizard",
	&"display_name": "Wizard",
	&"description": "AoE splash damage. Burns groups.",
	&"color": Color(0.70, 0.40, 0.90),
	&"radius": 22,
	&"attack_type": UnitData.AttackType.SPLASH,
	&"cost": 150,
	&"damage": 22.0,
	&"range_px": 128.0,
	&"fire_rate": 0.7,
	&"splash_radius": 48.0,
	&"projectile_speed": 280.0,
	&"can_hit_air": true,
}

# --- Towers unlocked via story progression (see levels.gd) ---

# Crossbowman: single-target burst DPS. Higher fire rate than Archer at slightly
# shorter range; rewards focus-firing priority targets. Fragile investment.
const Crossbowman := {
	&"id": &"crossbowman",
	&"display_name": "Crossbowman",
	&"description": "Rapid burst single-target. Shreds priority foes.",
	&"color": Color(0.85, 0.70, 0.30),
	&"radius": 20,
	&"attack_type": UnitData.AttackType.PROJECTILE,
	&"cost": 95,
	&"damage": 10.0,
	&"range_px": 140.0,
	&"fire_rate": 2.0,
	&"projectile_speed": 520.0,
	&"can_hit_air": true,
}

# Frost Mage: AoE + slow. Splash like Wizard but applies the Knight's slow flag
# to every enemy inside the splash radius. Lower damage than Wizard; its value
# is lock-down, not burst.
const FrostMage := {
	&"id": &"frost_mage",
	&"display_name": "Frost Mage",
	&"description": "AoE frost. Slows every enemy in the blast.",
	&"color": Color(0.45, 0.80, 0.95),
	&"radius": 22,
	&"attack_type": UnitData.AttackType.SPLASH,
	&"cost": 140,
	&"damage": 12.0,
	&"range_px": 120.0,
	&"fire_rate": 0.9,
	&"splash_radius": 52.0,
	&"projectile_speed": 300.0,
	&"can_hit_air": true,
	&"slows_on_hit": true,
	&"slow_factor": 0.55,
	&"slow_duration": 1.5,
}

# Catapult: long-range heavy siege. Very long range + large splash but very slow
# fire rate and can't hit air — the answer to dense ground clusters.
const Catapult := {
	&"id": &"catapult",
	&"display_name": "Catapult",
	&"description": "Long-range siege. Huge splash, slow reload.",
	&"color": Color(0.65, 0.55, 0.40),
	&"radius": 26,
	&"attack_type": UnitData.AttackType.SPLASH,
	&"cost": 200,
	&"damage": 40.0,
	&"range_px": 200.0,
	&"fire_rate": 0.35,
	&"splash_radius": 70.0,
	&"projectile_speed": 220.0,
	&"can_hit_air": false,
}

const ALL := [Soldier, Archer, Knight, Wizard, Crossbowman, FrostMage, Catapult]


static func make(key: Dictionary) -> UnitData:
	var d := UnitData.new()
	for k in key.keys():
		d.set(k, key[k])
	return d


## Look up a unit definition by id (StringName). Falls back to Soldier on miss
## (with a push_error) so the game stays playable if a level references an id
## that doesn't exist yet.
static func by_id(unit_id: StringName) -> UnitData:
	for def in ALL:
		if def[&"id"] == unit_id:
			return make(def)
	push_error("Unknown unit id: %s" % unit_id)
	return make(Soldier)


## The raw Dictionary definition for a unit id (no UnitData allocation).
## Useful when callers just want to read display_name/cost/etc.
static func def_for(unit_id: StringName) -> Dictionary:
	for def in ALL:
		if def[&"id"] == unit_id:
			return def
	push_error("Unknown unit id: %s" % unit_id)
	return Soldier
