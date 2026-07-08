class_name Enemies
## Static catalogue of enemy types.

const Goblin := {
	&"id": &"goblin",
	&"display_name": "Goblin",
	&"color": Color(0.55, 0.70, 0.35),
	&"radius": 14,
	&"max_hp": 30.0,
	&"speed": 80.0,
	&"gold_reward": 6,
}

const Skeleton := {
	&"id": &"skeleton",
	&"display_name": "Skeleton",
	&"color": Color(0.85, 0.85, 0.78),
	&"radius": 15,
	&"max_hp": 55.0,
	&"speed": 55.0,
	&"gold_reward": 9,
	&"armor": 2.0,
}

const Ghost := {
	&"id": &"ghost",
	&"display_name": "Ghost",
	&"color": Color(0.75, 0.85, 0.95, 0.7),
	&"radius": 16,
	&"max_hp": 45.0,
	&"speed": 70.0,
	&"gold_reward": 10,
}

const Bat := {
	&"id": &"bat",
	&"display_name": "Bat",
	&"color": Color(0.45, 0.35, 0.55),
	&"radius": 13,
	&"max_hp": 28.0,
	&"speed": 95.0,
	&"gold_reward": 8,
	&"is_flying": true,
}

const Demon := {
	&"id": &"demon",
	&"display_name": "Demon",
	&"color": Color(0.80, 0.25, 0.25),
	&"radius": 20,
	&"max_hp": 130.0,
	&"speed": 45.0,
	&"gold_reward": 20,
	&"armor": 4.0,
}

const Dragon := {
	&"id": &"dragon",
	&"display_name": "Dragon",
	&"color": Color(0.90, 0.50, 0.20),
	&"radius": 28,
	&"max_hp": 600.0,
	&"speed": 40.0,
	&"gold_reward": 100,
	&"is_flying": true,
	&"leaks_damage": 5,
}

const Wolf := {
	&"id": &"wolf",
	&"display_name": "Wolf",
	&"color": Color(0.55, 0.45, 0.35),
	&"radius": 14,
	&"max_hp": 42.0,
	&"speed": 130.0,
	&"gold_reward": 9,
}

const Troll := {
	&"id": &"troll",
	&"display_name": "Troll",
	&"color": Color(0.40, 0.55, 0.35),
	&"radius": 22,
	&"max_hp": 240.0,
	&"speed": 38.0,
	&"gold_reward": 32,
	&"armor": 3.0,
	&"regen": 8.0,
}

# --- Enemies introduced via story progression (see levels.gd) ---

# Cursed Skull: tankier skeleton variant. Heavier armor, slower — a wall to
# chip through. Punishes low-DMG spam (armor eats each hit).
const CursedSkull := {
	&"id": &"cursed_skull",
	&"display_name": "Cursed Skull",
	&"color": Color(0.55, 0.50, 0.65),
	&"radius": 16,
	&"max_hp": 70.0,
	&"speed": 50.0,
	&"gold_reward": 12,
	&"armor": 3.0,
}

# Wraith: glass-cannon flyer. Faster than a bat with a touch more HP — punishes
# builds that skimp on anti-air.
const Wraith := {
	&"id": &"wraith",
	&"display_name": "Wraith",
	&"color": Color(0.60, 0.45, 0.85, 0.75),
	&"radius": 15,
	&"max_hp": 35.0,
	&"speed": 105.0,
	&"gold_reward": 11,
	&"is_flying": true,
}

# Hellhound: armored wolf upgrade. Very fast + armor — needs burst or it chews
# through a defensive line before chip damage adds up.
const Hellhound := {
	&"id": &"hellhound",
	&"display_name": "Hellhound",
	&"color": Color(0.85, 0.40, 0.20),
	&"radius": 15,
	&"max_hp": 60.0,
	&"speed": 140.0,
	&"gold_reward": 14,
	&"armor": 2.0,
}

# Banshee: mid-tier pressure sponge. Lots of HP for its speed, no special trick
# — just a body that has to be focused down while everything else flows past.
const Banshee := {
	&"id": &"banshee",
	&"display_name": "Banshee",
	&"color": Color(0.80, 0.75, 0.95, 0.85),
	&"radius": 18,
	&"max_hp": 90.0,
	&"speed": 60.0,
	&"gold_reward": 16,
}

# Hydra: the finale boss of the first arc. Flying, huge HP, leaks 6 lives.
const Hydra := {
	&"id": &"hydra",
	&"display_name": "Hydra",
	&"color": Color(0.45, 0.30, 0.70),
	&"radius": 30,
	&"max_hp": 900.0,
	&"speed": 35.0,
	&"gold_reward": 150,
	&"is_flying": true,
	&"leaks_damage": 6,
}

# --- Enemies introduced via the extended story arc (levels 7-12) ---

# Vampire: regenerating undead. Heals as it advances, undoing chip damage like a
# Troll but faster and lighter — must be burst down before it self-sustains.
const Vampire := {
	&"id": &"vampire",
	&"display_name": "Vampire",
	&"color": Color(0.55, 0.12, 0.18),
	&"radius": 16,
	&"max_hp": 80.0,
	&"speed": 70.0,
	&"gold_reward": 15,
	&"regen": 6.0,
}

# Zombie: slow, relentless wall. High HP for its cost; pressure by attrition
# rather than speed — it just keeps coming.
const Zombie := {
	&"id": &"zombie",
	&"display_name": "Zombie",
	&"color": Color(0.48, 0.62, 0.42),
	&"radius": 16,
	&"max_hp": 90.0,
	&"speed": 35.0,
	&"gold_reward": 10,
	&"armor": 1.0,
}

# Mummy: tomb guardian. Heavily armored and tough — armor eats fast light hits,
# so it wants burst or splash, not chip.
const Mummy := {
	&"id": &"mummy",
	&"display_name": "Mummy",
	&"color": Color(0.82, 0.74, 0.48),
	&"radius": 18,
	&"max_hp": 120.0,
	&"speed": 45.0,
	&"gold_reward": 14,
	&"armor": 3.0,
}

# Orc: disciplined warband infantry. Solid HP + armor at a steady pace — the
# dependable backbone of an orc assault.
const Orc := {
	&"id": &"orc",
	&"display_name": "Orc",
	&"color": Color(0.50, 0.58, 0.32),
	&"radius": 17,
	&"max_hp": 110.0,
	&"speed": 60.0,
	&"gold_reward": 14,
	&"armor": 2.0,
}

# Witch: hexing flyer. Frail but airborne and quick — punishes defences that
# dropped their anti-air after the early arc.
const Witch := {
	&"id": &"witch",
	&"display_name": "Witch",
	&"color": Color(0.35, 0.20, 0.55),
	&"radius": 15,
	&"max_hp": 60.0,
	&"speed": 75.0,
	&"gold_reward": 16,
	&"is_flying": true,
}

# Gargoyle: stone sentinel. Flying AND armored — a heavy air unit that shrugs off
# arrows and demands concentrated anti-air.
const Gargoyle := {
	&"id": &"gargoyle",
	&"display_name": "Gargoyle",
	&"color": Color(0.46, 0.46, 0.52),
	&"radius": 18,
	&"max_hp": 150.0,
	&"speed": 55.0,
	&"gold_reward": 22,
	&"armor": 4.0,
	&"is_flying": true,
}

# Demon Lord: the true finale boss. Flying, colossal HP, leaks 7 lives — the
# capstone threat of the extended arc, looming over the Gates of the Abyss.
const DemonLord := {
	&"id": &"demon_lord",
	&"display_name": "Demon Lord",
	&"color": Color(0.55, 0.10, 0.12),
	&"radius": 30,
	&"max_hp": 1100.0,
	&"speed": 35.0,
	&"gold_reward": 200,
	&"is_flying": true,
	&"leaks_damage": 7,
}

const ALL := [Goblin, Skeleton, Ghost, Bat, Wolf, Demon, Troll, Dragon,
	CursedSkull, Wraith, Hellhound, Banshee, Hydra,
	Vampire, Zombie, Mummy, Orc, Witch, Gargoyle, DemonLord]


static func make(key: Dictionary) -> EnemyData:
	var d := EnemyData.new()
	for k in key.keys():
		d.set(k, key[k])
	return d


static func by_id(enemy_id: StringName) -> EnemyData:
	for def in ALL:
		if def[&"id"] == enemy_id:
			return make(def)
	push_error("Unknown enemy id: %s" % enemy_id)
	return make(Goblin)
