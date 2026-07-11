class_name Upgrades
## Per-unit upgrade tiers. Each unit has up to MAX_LEVEL tiers (levels 1..MAX).
## A tier is a Dictionary of stat multipliers + a gold cost.
##
## Multipliers are CUMULATIVE from base: applying tier N multiplies the unit's
## BASE stats by tiers[0..N] combined. Tower.upgrade() handles the stacking.
##
## Design goals:
##   - Tier 1 is a cheap, noticeable power spike (feels rewarding to buy).
##   - Tier 2 is a bigger investment that specialises the unit.
##   - Costs scale so fully upgrading is a real economy commitment.

const MAX_LEVEL: int = 2

# Per-unit tier definitions. Each tier:
#   { cost, damage, range, fire_rate, splash, note }
# Multiplier 1.0 = unchanged. `note` shows in the UI panel.
const TIERS := {
	&"soldier": [
		{ &"cost": 40,  &"damage": 1.8, &"range": 1.15, &"fire_rate": 1.30, &"splash": 1.0,
		  &"note": "Sharper blade, faster swings." },
		{ &"cost": 80,  &"damage": 1.9, &"range": 1.15, &"fire_rate": 1.35, &"splash": 1.0,
		  &"note": "Veteran: heavy strikes, relentless pace." },
	],
	&"archer": [
		{ &"cost": 60,  &"damage": 1.8, &"range": 1.25, &"fire_rate": 1.25, &"splash": 1.0,
		  &"note": "Eagle eye: longer range, harder hits." },
		{ &"cost": 120, &"damage": 1.9, &"range": 1.25, &"fire_rate": 1.40, &"splash": 1.0,
		  &"note": "Marksman: rapid fire across the field." },
	],
	&"knight": [
		{ &"cost": 80,  &"damage": 1.7, &"range": 1.15, &"fire_rate": 1.25, &"splash": 1.0,
		  &"note": "Plate armour, heavier blows." },
		{ &"cost": 160, &"damage": 1.8, &"range": 1.15, &"fire_rate": 1.30, &"splash": 1.0,
		  &"note": "Champion: deep slow, crushing damage." },
	],
	&"wizard": [
		{ &"cost": 110, &"damage": 1.7, &"range": 1.20, &"fire_rate": 1.15, &"splash": 1.35,
		  &"note": "Wider explosions, hotter flame." },
		{ &"cost": 220, &"damage": 1.8, &"range": 1.20, &"fire_rate": 1.25, &"splash": 1.40,
		  &"note": "Archmage: massive blasts, fast casting." },
	],
	# --- Towers unlocked via story progression ---
	&"crossbowman": [
		{ &"cost": 70,  &"damage": 1.7, &"range": 1.15, &"fire_rate": 1.30, &"splash": 1.0,
		  &"note": "Cranked draw: tighter groups, faster reload." },
		{ &"cost": 140, &"damage": 1.8, &"range": 1.20, &"fire_rate": 1.45, &"splash": 1.0,
		  &"note": "Marksman: a bolt for every throat." },
	],
	&"frost_mage": [
		{ &"cost": 90,  &"damage": 1.6, &"range": 1.15, &"fire_rate": 1.20, &"splash": 1.25,
		  &"note": "Deeper frost: wider chill, longer slow." },
		{ &"cost": 180, &"damage": 1.7, &"range": 1.20, &"fire_rate": 1.30, &"splash": 1.35,
		  &"note": "Blizzard: the field itself turns against them." },
	],
	&"catapult": [
		{ &"cost": 120, &"damage": 1.7, &"range": 1.15, &"fire_rate": 1.20, &"splash": 1.25,
		  &"note": "Heavier shot: bigger blasts, longer reach." },
		{ &"cost": 240, &"damage": 1.9, &"range": 1.20, &"fire_rate": 1.30, &"splash": 1.40,
		  &"note": "Siege master: the ground itself shatters." },
	],
	# --- Towers unlocked via the extended story arc (levels 7-12) ---
	&"cleric": [
		{ &"cost": 90,  &"damage": 1.7, &"range": 1.15, &"fire_rate": 1.20, &"splash": 1.30,
		  &"note": "Brighter halo: wider dazzle, harder smite." },
		{ &"cost": 180, &"damage": 1.8, &"range": 1.20, &"fire_rate": 1.30, &"splash": 1.40,
		  &"note": "High priest: holy light lays the wicked low." },
	],
	&"bard": [
		{ &"cost": 80,  &"damage": 1.6, &"range": 1.15, &"fire_rate": 1.30, &"splash": 1.25,
		  &"note": "Louder chorus: wider waves, lingering drag." },
		{ &"cost": 160, &"damage": 1.7, &"range": 1.20, &"fire_rate": 1.40, &"splash": 1.35,
		  &"note": "Virtuoso: a symphony that stops armies cold." },
	],
	&"prince": [
		{ &"cost": 130, &"damage": 1.7, &"range": 1.20, &"fire_rate": 1.30, &"splash": 1.0,
		  &"note": "Royal drill: faster volleys, longer reach." },
		{ &"cost": 260, &"damage": 1.9, &"range": 1.25, &"fire_rate": 1.45, &"splash": 1.0,
		  &"note": "Warrior king: every shot finds its mark." },
	],
	&"princess": [
		{ &"cost": 100, &"damage": 1.7, &"range": 1.20, &"fire_rate": 1.25, &"splash": 1.0,
		  &"note": "Keener enchantments: longer bolts, deeper slow." },
		{ &"cost": 200, &"damage": 1.8, &"range": 1.30, &"fire_rate": 1.35, &"splash": 1.0,
		  &"note": "Sovereign of frost and starlight, unerring." },
	],
}


static func tiers_for(unit_id: StringName) -> Array:
	# Always return an Array (possibly empty) so callers can index safely.
	if TIERS.has(unit_id):
		return TIERS[unit_id]
	return []


## Cost to reach the NEXT level from `current_level`, or -1 if already maxed.
static func next_cost(unit_id: StringName, current_level: int) -> int:
	var tiers := tiers_for(unit_id)
	if current_level >= tiers.size():
		return -1
	return tiers[current_level][&"cost"]


static func is_maxed(unit_id: StringName, current_level: int) -> bool:
	return current_level >= tiers_for(unit_id).size()
