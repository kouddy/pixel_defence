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

const ALL := [Soldier, Archer, Knight, Wizard]


static func make(key: Dictionary) -> UnitData:
	var d := UnitData.new()
	for k in key.keys():
		d.set(k, key[k])
	return d
