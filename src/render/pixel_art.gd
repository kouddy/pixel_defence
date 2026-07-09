class_name PixelArt
## Library of pixel-art patterns (ASCII grids) + a shaded palette.
## Conventions:
##   - Grid is 16 columns wide (towers) so x-centering is consistent.
##   - Lighting comes from the TOP-LEFT: light tones on top/left, shadow on bottom/right.
##   - ' ' or '.' = transparent.
##   - Each single character maps to a Color via PALETTE.

const PALETTE := {
	# outline — lifted to a saturated mid-dark so it reads against the dark ground
	"K": Color(0.16, 0.13, 0.21),
	# steel (armor / helmets)
	"A": Color(0.45, 0.50, 0.60),
	"I": Color(0.68, 0.74, 0.84),
	"i": Color(0.88, 0.92, 0.97),
	# skin
	"E": Color(0.62, 0.45, 0.32),
	"S": Color(0.88, 0.66, 0.48),
	"s": Color(0.96, 0.82, 0.64),
	# red
	"R": Color(0.58, 0.18, 0.16),
	"r": Color(0.86, 0.32, 0.26),
	"o": Color(0.97, 0.55, 0.30),
	# green
	"G": Color(0.30, 0.55, 0.26),
	"g": Color(0.50, 0.75, 0.40),
	"q": Color(0.70, 0.90, 0.55),
	# blue
	"B": Color(0.28, 0.45, 0.72),
	"b": Color(0.45, 0.64, 0.90),
	"c": Color(0.66, 0.82, 0.98),
	# purple
	"P": Color(0.46, 0.27, 0.66),
	"p": Color(0.66, 0.44, 0.86),
	"u": Color(0.82, 0.63, 0.95),
	# gold / yellow
	"Y": Color(0.66, 0.50, 0.14),
	"y": Color(0.92, 0.78, 0.26),
	"z": Color(0.99, 0.90, 0.50),
	"Z": Color(1.0, 0.96, 0.66),   # bright highlight gold (lance, blade edge)
	# bone / white (skeleton, beard)
	"W": Color(0.66, 0.64, 0.58),
	"n": Color(0.86, 0.84, 0.76),
	"w": Color(0.98, 0.97, 0.92),
	# brown (wood, leather, bow)
	"M": Color(0.36, 0.24, 0.14),
	"m": Color(0.55, 0.38, 0.22),
	# misc
	"d": Color(0.28, 0.25, 0.32),    # dark gray
	"k": Color(0.10, 0.08, 0.06),    # near-black (arrow-slit shadow)
	# ghost (translucent light blue)
	"l": Color(0.74, 0.88, 0.98, 0.88),
	"L": Color(0.90, 0.96, 1.0, 0.97),
	# goblin hide (yellow-green)
	"H": Color(0.36, 0.52, 0.22),
	"h": Color(0.56, 0.72, 0.38),
	"j": Color(0.74, 0.88, 0.52),
	# fire / glow
	"f": Color(0.98, 0.58, 0.18),
	"F": Color(0.99, 0.88, 0.32),
	# stone (mountains, castle)
	"T": Color(0.36, 0.36, 0.42),
	"t": Color(0.54, 0.54, 0.60),
	"e": Color(0.72, 0.72, 0.78),
	# snow caps
	"N": Color(0.92, 0.94, 0.98),
}

# ============================ DIRECTION CONSTANTS ============================
# Four-way facing for characters. Standard RPG mapping relative to the screen:
#   FRONT  = facing the camera  (target is BELOW the tower)
#   BACK   = facing away        (target is ABOVE the tower)
#   RIGHT  = facing east        (target is to the right)
#   LEFT   = facing west        (target is to the left; rendered by flipping RIGHT)
const DIR_FRONT := &"front"
const DIR_BACK  := &"back"
const DIR_LEFT  := &"left"
const DIR_RIGHT := &"right"
const STANCE_IDLE    := false
const STANCE_ATTACK  := true

# ============================ SOLDIER SVG ART ============================
# The soldier ships as detailed vector art (assets/soldier_*.svg) imported as
# textures. The side-facing SVGs look to the LEFT, so the RIGHT pose is the LEFT
# sprite drawn mirrored (flip_h). Map each (facing, stance) to a texture + the
# horizontal-flip flag the caller should apply.
#
# Paths use load() (cached by Godot). The project imports SVGs at scale 1.0 and
# nearest-neighbour by default; for this art we override the texture to LINEAR
# filtering at load time so the detailed shading downscales cleanly.
const SOLDIER_TEX_FRONT_IDLE    := preload("res://assets/soldier_front_non_attack.svg")
const SOLDIER_TEX_FRONT_ATTACK  := preload("res://assets/soldier_front_attack.svg")
const SOLDIER_TEX_BACK_IDLE     := preload("res://assets/soldier_back_non_attack.svg")
const SOLDIER_TEX_BACK_ATTACK   := preload("res://assets/soldier_back_attack.svg")
const SOLDIER_TEX_SIDE_IDLE     := preload("res://assets/soldier_left_non_attack.svg")
const SOLDIER_TEX_SIDE_ATTACK   := preload("res://assets/soldier_left_attack.svg")

const ARCHER_TEX_FRONT_IDLE    := preload("res://assets/archer_front_non_attack.svg")
const ARCHER_TEX_FRONT_ATTACK  := preload("res://assets/archer_front_attack.svg")
const ARCHER_TEX_BACK_IDLE     := preload("res://assets/archer_back_non_attack.svg")
const ARCHER_TEX_BACK_ATTACK   := preload("res://assets/archer_back_attack.svg")
const ARCHER_TEX_SIDE_IDLE     := preload("res://assets/archer_left_non_attack.svg")
const ARCHER_TEX_SIDE_ATTACK   := preload("res://assets/archer_left_attack.svg")

const KNIGHT_TEX_FRONT_IDLE_PATH    := "res://assets/knight_front_non_attack.svg"
const KNIGHT_TEX_FRONT_ATTACK_PATH  := "res://assets/knight_front_attack.svg"
const KNIGHT_TEX_BACK_IDLE_PATH     := "res://assets/knight_back_non_attack.svg"
const KNIGHT_TEX_BACK_ATTACK_PATH   := "res://assets/knight_back_attack.svg"
const KNIGHT_TEX_SIDE_IDLE_PATH     := "res://assets/knight_left_non_attack.svg"
const KNIGHT_TEX_SIDE_ATTACK_PATH   := "res://assets/knight_left_attack.svg"

const WIZARD_TEX_FRONT_IDLE_PATH    := "res://assets/wizard_front_non_attack.svg"
const WIZARD_TEX_FRONT_ATTACK_PATH  := "res://assets/wizard_front_attack.svg"
const WIZARD_TEX_BACK_IDLE_PATH     := "res://assets/wizard_back_non_attack.svg"
const WIZARD_TEX_BACK_ATTACK_PATH   := "res://assets/wizard_back_attack.svg"
const WIZARD_TEX_SIDE_IDLE_PATH     := "res://assets/wizard_left_non_attack.svg"
const WIZARD_TEX_SIDE_ATTACK_PATH   := "res://assets/wizard_left_attack.svg"

# --- Crossbowman (detailed art shipped as bowman_*.svg) ---
# The bow-themed SVG files are named "bowman_*"; they back the existing
# "crossbowman" unit, upgrading it from ASCII to texture art.
const CROSSBOWMAN_TEX_FRONT_IDLE_PATH    := "res://assets/bowman_front_non_attack.svg"
const CROSSBOWMAN_TEX_FRONT_ATTACK_PATH  := "res://assets/bowman_front_attack.svg"
const CROSSBOWMAN_TEX_BACK_IDLE_PATH     := "res://assets/bowman_back_non_attack.svg"
const CROSSBOWMAN_TEX_BACK_ATTACK_PATH   := "res://assets/bowman_back_attack.svg"
const CROSSBOWMAN_TEX_SIDE_IDLE_PATH     := "res://assets/bowman_left_non_attack.svg"
const CROSSBOWMAN_TEX_SIDE_ATTACK_PATH   := "res://assets/bowman_left_attack.svg"

# --- Cleric ---
const CLERIC_TEX_FRONT_IDLE_PATH    := "res://assets/cleric_front_non_attack.svg"
const CLERIC_TEX_FRONT_ATTACK_PATH  := "res://assets/cleric_front_attack.svg"
const CLERIC_TEX_BACK_IDLE_PATH     := "res://assets/cleric_back_non_attack.svg"
const CLERIC_TEX_BACK_ATTACK_PATH   := "res://assets/cleric_back_attack.svg"
const CLERIC_TEX_SIDE_IDLE_PATH     := "res://assets/cleric_left_non_attack.svg"
const CLERIC_TEX_SIDE_ATTACK_PATH   := "res://assets/cleric_left_attack.svg"

# --- Bard ---
const BARD_TEX_FRONT_IDLE_PATH    := "res://assets/bard_front_non_attack.svg"
const BARD_TEX_FRONT_ATTACK_PATH  := "res://assets/bard_front_attack.svg"
const BARD_TEX_BACK_IDLE_PATH     := "res://assets/bard_back_non_attack.svg"
const BARD_TEX_BACK_ATTACK_PATH   := "res://assets/bard_back_attack.svg"
const BARD_TEX_SIDE_IDLE_PATH     := "res://assets/bard_left_non_attack.svg"
const BARD_TEX_SIDE_ATTACK_PATH   := "res://assets/bard_left_attack.svg"

# --- Catapult (no back_attack art yet; BACK+attack falls back to BACK idle) ---
const CATAPULT_TEX_FRONT_IDLE_PATH    := "res://assets/catapult_front_non_attack.svg"
const CATAPULT_TEX_FRONT_ATTACK_PATH  := "res://assets/catapult_front_attack.svg"
const CATAPULT_TEX_BACK_IDLE_PATH     := "res://assets/catapult_back_non_attack.svg"
const CATAPULT_TEX_SIDE_IDLE_PATH     := "res://assets/catapult_left_non_attack.svg"
const CATAPULT_TEX_SIDE_ATTACK_PATH   := "res://assets/catapult_left_attack.svg"

# Side art faces LEFT, so the RIGHT facing needs a horizontal flip.
#   facing LEFT  -> flip_h = false (art already faces left)
#   facing RIGHT -> flip_h = true  (mirror the left-facing art)
const SIDE_FLIP_FOR_LEFT := false
const SIDE_FLIP_FOR_RIGHT := true

## On-screen edge length for the soldier art, in pixels. Sized to match the
## footprint of the old 16-row ASCII grid at pixel_size 2.0 (≈32px tall) so the
## new art drops into the existing tile scale without re-tuning placement.
const SOLDIER_DRAW_SIZE := 36.0


## Returns the soldier texture for a (facing, stance) pair.
static func _soldier_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return SOLDIER_TEX_FRONT_ATTACK if attacking else SOLDIER_TEX_FRONT_IDLE
		DIR_BACK:
			return SOLDIER_TEX_BACK_ATTACK if attacking else SOLDIER_TEX_BACK_IDLE
		# SIDE covers LEFT and RIGHT; mirroring is the caller's job.
		DIR_LEFT, DIR_RIGHT:
			return SOLDIER_TEX_SIDE_ATTACK if attacking else SOLDIER_TEX_SIDE_IDLE
	return SOLDIER_TEX_FRONT_IDLE


## Returns the archer texture for a (facing, stance) pair.
static func _archer_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return ARCHER_TEX_FRONT_ATTACK if attacking else ARCHER_TEX_FRONT_IDLE
		DIR_BACK:
			return ARCHER_TEX_BACK_ATTACK if attacking else ARCHER_TEX_BACK_IDLE
		DIR_LEFT, DIR_RIGHT:
			return ARCHER_TEX_SIDE_ATTACK if attacking else ARCHER_TEX_SIDE_IDLE
	return ARCHER_TEX_FRONT_IDLE


## Returns the knight texture for a (facing, stance) pair.
static func _knight_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(KNIGHT_TEX_FRONT_ATTACK_PATH if attacking else KNIGHT_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			return load(KNIGHT_TEX_BACK_ATTACK_PATH if attacking else KNIGHT_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(KNIGHT_TEX_SIDE_ATTACK_PATH if attacking else KNIGHT_TEX_SIDE_IDLE_PATH)
	return load(KNIGHT_TEX_FRONT_IDLE_PATH)


## Returns the wizard texture for a (facing, stance) pair.
static func _wizard_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(WIZARD_TEX_FRONT_ATTACK_PATH if attacking else WIZARD_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			return load(WIZARD_TEX_BACK_ATTACK_PATH if attacking else WIZARD_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(WIZARD_TEX_SIDE_ATTACK_PATH if attacking else WIZARD_TEX_SIDE_IDLE_PATH)
	return load(WIZARD_TEX_FRONT_IDLE_PATH)


## Returns the crossbowman texture for a (facing, stance) pair.
## Art is the bowman_*.svg set (see constants above).
static func _crossbowman_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(CROSSBOWMAN_TEX_FRONT_ATTACK_PATH if attacking else CROSSBOWMAN_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			return load(CROSSBOWMAN_TEX_BACK_ATTACK_PATH if attacking else CROSSBOWMAN_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(CROSSBOWMAN_TEX_SIDE_ATTACK_PATH if attacking else CROSSBOWMAN_TEX_SIDE_IDLE_PATH)
	return load(CROSSBOWMAN_TEX_FRONT_IDLE_PATH)


## Returns the cleric texture for a (facing, stance) pair.
static func _cleric_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(CLERIC_TEX_FRONT_ATTACK_PATH if attacking else CLERIC_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			return load(CLERIC_TEX_BACK_ATTACK_PATH if attacking else CLERIC_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(CLERIC_TEX_SIDE_ATTACK_PATH if attacking else CLERIC_TEX_SIDE_IDLE_PATH)
	return load(CLERIC_TEX_FRONT_IDLE_PATH)


## Returns the bard texture for a (facing, stance) pair.
static func _bard_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(BARD_TEX_FRONT_ATTACK_PATH if attacking else BARD_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			return load(BARD_TEX_BACK_ATTACK_PATH if attacking else BARD_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(BARD_TEX_SIDE_ATTACK_PATH if attacking else BARD_TEX_SIDE_IDLE_PATH)
	return load(BARD_TEX_FRONT_IDLE_PATH)


## Returns the catapult texture for a (facing, stance) pair.
## NOTE: there is no catapult_back_attack.svg yet, so the BACK-facing attack
## pose reuses the BACK idle art until that frame is supplied.
static func _catapult_tex(facing: String, attacking: bool) -> Texture2D:
	match facing:
		DIR_FRONT:
			return load(CATAPULT_TEX_FRONT_ATTACK_PATH if attacking else CATAPULT_TEX_FRONT_IDLE_PATH)
		DIR_BACK:
			# No back-attack art: fall back to the idle back pose.
			return load(CATAPULT_TEX_BACK_IDLE_PATH)
		DIR_LEFT, DIR_RIGHT:
			return load(CATAPULT_TEX_SIDE_ATTACK_PATH if attacking else CATAPULT_TEX_SIDE_IDLE_PATH)
	return load(CATAPULT_TEX_FRONT_IDLE_PATH)


## Whether a given unit should render via SVG textures (texture mode) rather
## than the ASCII grid.
static func has_texture_art(unit_id: String) -> bool:
	return unit_id in [&"soldier", &"archer", &"knight", &"wizard",
		&"crossbowman", &"cleric", &"bard", &"catapult"]

# ============================ DEFENDERS ============================

# Soldier — canonical single orientation (kept for shop previews / fallback).
# Aliases the FRONT idle grid so there is one source of truth for the front look.
const SOLDIER := [
	"................",
	"......I.........",   # helmet plume
	"......I.........",
	"....KKiiiiKK....",   # steel helmet
	"...KiiiiiiiiK...",
	"...KiIIIIIIiK...",   # visor
	"...KiAiiAiAik...",   # eye slits
	"...KiiiiiiiiK...",
	"....KSSSSSSK....",   # chin
	"...AArrrrrrAA.i.",   # shoulders + sword blade
	"..ArrrrrrrrrRA.i",   # shield body + blade
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"...KArrrrrrAK.i.",   # belt + pommel
	"....Kmm..mmK....",   # legs
	"...KKKK..KKKK...",
]

# --- Soldier, FRONT (toward camera) -------------------------------------
# Plume + visor visible, sword held upright at rest (idle) / raised overhead
# then chopped down (attack).
const SOLDIER_FRONT_IDLE := [
	"................",
	"......I.........",   # helmet plume
	"......I.........",
	"....KKiiiiKK....",   # steel helmet
	"...KiiiiiiiiK...",
	"...KiIIIIIIiK...",   # visor
	"...KiAiiAiAik...",   # eye slits (front: both eyes)
	"...KiiiiiiiiK...",
	"....KSSSSSSK....",   # chin
	"...AArrrrrrAA.i.",   # shoulders + sword blade (at side)
	"..ArrrrrrrrrRA.i",   # shield body
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"...KArrrrrrAK.i.",   # belt + pommel
	"....Kmm..mmK....",   # legs
	"...KKKK..KKKK...",
]

const SOLDIER_FRONT_ATTACK := [
	"....i...........",   # sword pommel raised overhead
	"....Z...........",
	"....Z...........",
	"....Z...........",   # blade up
	"....Z...........",
	"...KiiiiiiiiK...",   # helmet tilted to strike
	"...KiIIIIIIiK...",   # visor
	"...KiAiiAiAik...",   # eyes
	"...KSSSSSSSSK...",   # jaw forward
	"...ArrrrrrrRAZ..",   # shoulders + sword coming down
	"..ArrrrrrrrrRAZ.",   # shield + blade tip
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"...KArrrrrrAK.i.",
	"....Kmm..mmK....",
	"...KKKK..KKKK...",
]

# --- Soldier, BACK (away from camera) -----------------------------------
# No eyes; plume + helmet back + scabbard visible. Attack = overhead chop.
const SOLDIER_BACK_IDLE := [
	"................",
	"......I.........",   # plume (seen from behind)
	"......I.........",
	"....KKiiiiKK....",   # back of helmet
	"...KiiiiiiiiK...",
	"...KiiiiiiiiK...",
	"...KiiiiiiiiK...",   # no visor eyes from behind
	"...KiiiiiiiiK...",
	"....KAAAAAAK....",   # collar / back of neck
	"...AArrrrrrAA.i.",   # shoulders + scabbard
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"...KArrrrrrAK.i.",
	"....Kmm..mmK....",
	"...KKKK..KKKK...",
]

const SOLDIER_BACK_ATTACK := [
	"....i...........",   # sword raised overhead
	"....Z...........",
	"....Z...........",
	"....Z...........",
	"....Z...........",
	"...KiiiiiiiiK...",   # helmet back
	"...KiiiiiiiiK...",
	"...KiiiiiiiiK...",
	"...KAAAAAAA K...",   # collar straining forward
	"...ArrrrrrrRAZ..",   # sword chop
	"..ArrrrrrrrrRAZ.",
	"..ArrrrrrrrrRA.i",
	"..ArrrrrrrrrRA.i",
	"...KArrrrrrAK.i.",
	"....Kmm..mmK....",
	"...KKKK..KKKK...",
]

# --- Soldier, SIDE (drawn facing RIGHT; flipped for LEFT) ---------------
# Profile: one eye, helmet profile, sword forward in a thrust.
const SOLDIER_SIDE_IDLE := [
	"................",
	"......I.........",   # plume trails back
	"......I.........",
	"....KKiiiiKK....",   # helmet profile
	"...KiiiiiiiK....",
	"...KiiIIIIIK....",   # brow
	"...KiiiAiiiK....",   # single eye (profile)
	"...KiiiiiiiK....",
	"....KSSSSSK.....",   # chin/jaw
	"....AArrrrAA.i..",   # shoulder + sword at side
	"...ArrrrrrrRA.i.",   # shield (small, edge-on)
	"...ArrrrrrrRA.i.",
	"...ArrrrrrrRA.i.",
	"...KArrrrrAK.i..",
	"....Kmm.mmK.....",   # legs (one slightly forward)
	"...KKKK.KKKK....",
]

const SOLDIER_SIDE_ATTACK := [
	"................",
	"......I.........",
	"......I.........",
	"....KKiiiiKKZ...",   # helmet + sword thrust forward (right)
	"...KiiiiiiiZ....",   # blade
	"...KiiIIIIIZ....",
	"...KiiiAiiiZm..",   # eye + pommel extended
	"...Kiiiiiiim...",   # arm
	"....KSSSSSK.....",
	"....AArrrrAA....",   # shoulder leaning into thrust
	"...ArrrrrrrRA.i.",
	"...ArrrrrrrRA.i.",
	"...ArrrrrrrRA.i.",
	"...KArrrrrAK.i..",
	"....Kmm.mmK.....",
	"...KKKK.KKKK....",
]

const ARCHER := [
	"................",
	".......q........",   # hood tip
	"......gqg.......",
	".....gGGg.......",
	"....gGssGg......",   # hood + face
	"...ggG..Ggg.....",   # eyes
	"....GGssGG..M...",   # bowstring + quiver
	".....GGGG..mM...",
	"....zGGGGz..mM..",   # bow arc (z)
	"...zzGGGGzz.mM..",
	"..zz.GGGG.zz.m..",   # bow limbs splay
	"...zzGGGGzz.m...",
	"....qqGGqq..m...",   # arrow shaft
	"....Kqq..qqK....",   # legs
	"...Kmm....mmK...",
	"..KKKK....KKKK..",
]

const KNIGHT := [
	"................",
	"......i.........",   # plume
	"......i.........",
	"....KKiiKK......",   # helm
	"...KiiiiiiK.z...",   # face + lance tip
	"...KiIIIIiK.mZ..",   # visor + lance shaft
	"...KiiiiiiK.mZ..",
	"....KiiiiK.mZ...",   # arm + lance
	"...bKIIIIKb.m...",   # armored torso + lance
	"..bbKKIIKKbbbb..",   # horse withers + head base
	"..bbHHHHHHHHbb..",   # horse neck/head (H)
	"..MbbbbbbbbMbm..",   # horse barrel
	"MMMmmmmmmmmMMm..",   # back/saddle
	"MMmmmmmmmmmmm...",   # belly
	".MM.MMM.MMM.MM..",   # four legs
	".KK.KKK.KKK.KK..",   # hooves
]

const WIZARD := [
	"................",
	".......z........",   # hat star tip
	"......pz........",
	".....ppu........",   # purple hat
	"....pppu........",
	"...ppppp........",   # swept hat
	"..PPPPPPP.......",   # brim
	"..PnnnnnP.......",   # hair
	"..PnSSSnP...z...",   # face + staff orb
	"..PnwwwwP...Y...",   # beard + staff shaft
	"..PnwwwwP...Y...",
	"...PnwwnP...Y...",
	"...PnnnnP...m...",   # staff base
	"...PPmmPP...m...",   # robe
	"....KmmmmK......",
	"....Km..mK......",
]

# ============================ ENEMIES ============================

const GOBLIN := [
	".Hh........hH...",
	".HHh......hHH...",
	".hHHh....hHHh...",
	".hhHHHjjHHHhh...",
	".hjjjjjjjjjjh...",
	".hjjjjjjjjjjh...",
	".jjjjjjjjjjjj...",
	".hjjWWjjWWjjh...",
	".hjjWWjjWWjjh...",
	".hjjjjjjjjjjh...",
	"..hjjKKKKjjh....",
	"...hjjjjjjh.....",
	"....hjjjjh......",
	"....hh..hh......",
	"...HHH..HHH.....",
]

const SKELETON := [
	"....KKKKKK......",
	"...KnnnnnnK.....",
	"..KnnnnnnnnK....",
	".KnKKnnnnKKnK...",
	".KnddKnnKddnK...",   # eye sockets (dark) -- using d for socket
	".KnKKnnnnKKnK...",
	"..KnnnnnnnnK....",
	"...KnnKKnnK.....",   # teeth
	"....KKnnKK......",
	"...nWnWnWnW.....",   # ribcage (alternating)
	"...nnnnnnnn.....",
	"....nn..nn......",
	"....KK..KK......",
	"...nnn..nnn.....",
	"..KKKK..KKKK....",
]

const GHOST := [
	"....LLLL........",
	"...LlllllL......",
	"..LllllllllL....",
	".LlllKKllKKlL...",   # hollow eyes
	".LlllKKllKKlL...",
	".LllllllllllL...",
	".LllllllllllL...",
	".LllllllllllL...",
	".LllllllllllL...",
	".LllllllllllL...",
	".LllllllllllL...",
	".LllllllllllL...",   # wavy bottom
	".Ll..lL..lL..l..",
	".L....L....L....",
]

const BAT := [
	"H..............H",
	"Hh............hH",
	"Hhh..........hhH",
	"Hhhh........hhhH",
	"Hhhhh......hhhhH",
	"HhhhhHH..HHhhhhH",
	".HhhhhHHHHhhhhH.",
	"..HhhhhhhhhhhH..",
	"..HhhhrrrrhhhH..",   # body (r = red eyes band)
	"..HhhHrrrrHhhH..",
	"...HHH....HHH...",   # fangs
	"................",
]

const WOLF := [
	"................",
	"................",
	"...Hh......hH...",
	"..HHHh....hHHH..",
	".HhhHHhhhhHHhhH.",
	".HhKKKhhhhKKKhH.",   # ears + brow
	".HhhRrhRRhrRhhH.",   # eyes
	".HhhhhmmmmhhhhH.",   # snout
	".HhhKKmmmmKKhhH.",   # fangs
	"..HhhhhhhhhhhH..",
	"..HHhhhhhhhhhH..",
	"...Hhh....hhhH..",   # legs
	"...HH......HH...",
	".HHHH......HHHH.",
	"................",
]

const TROLL := [
	"................",
	"..Ggg......ggG..",   # mossy head bumps
	".gGGGg....gGGGg.",
	".gGGGGGggGGGGGg.",
	".gGKKGGggGGKKgG.",   # brow
	".gGKKGGggGGKKgG.",   # glowing eyes
	".gGGGGgmmgGGGGg.",   # broken teeth
	".gGGGGgmmgGGGGg.",
	".gGGgKKKKKKgGGg.",
	"..gGGGGGGGGGg...",
	".gGggGGGGGGggGg.",
	".gGggGGGGGGggGg.",
	".gKKgggGGgggKKg.",
	"..KKK......KKK..",
	".KKKK......KKKK.",
	"................",
]

const DEMON := [
	".Ro........oR...",   # horn tips
	".RRo......oRR...",
	".rRRo....oRRr...",
	".rrRRrrrrRRrr...",
	".rrrRoooorrrrr..",   # brow
	".rrrKrrrrKrrrr..",   # glowing eyes (K sockets)
	".rrroFrrFoorrr..",   # fire eyes (F)
	".rrrrrrrrrrrrr..",
	"..rrrKKKKrrrr...",   # mouth/fangs
	"...rrrrrrrr.....",
	"...rrrrrrrr.....",
	"...rr....rr.....",
	"...KK....KK.....",
	"..KKKK..KKKK....",
	"................",
]

const DRAGON := [
	"................",
	"...RR........RR.",   # horns
	"..rRRo......oRRr",   # horn curves
	".rrRRRo....oRRRr",
	".rrrrRooccRoooof",   # head + eye (c) + fire breath (f)
	".rrrrrRoccRfffff",
	".GGrrrrrrrrGGGGf",   # green scale neck
	"GGGGgrrrrrrGGGG.",
	"GGGGGGggrGGGGG..",   # wing
	"GGGGGGGGGGGGG...",
	"qGGGGGGGGGGG....",
	"qGGGGGGGGGG.....",
	".qGGGGGGGG......",
	"..KGGGKKGGG.....",
	"..KGG..KGG......",
	".KKKK..KKKK.....",
]


# ============================ MAP PROPS ============================

const TREE := [
	"................",
	"................",
	"......q.........",
	".....qgq........",
	"....qgGgq.......",
	"...qgGGGgq......",
	"..qgGGGGGgq.....",
	"...qgGGGgq......",
	"....qgGgq.......",
	".....qgq........",
	"......mq........",
	"......mM........",
	"......mM........",
	".....KmMK.......",
	"................",
	"................",
]

const ROCK := [
	"................",
	"................",
	"................",
	"................",
	"................",
	"................",
	".....eeeee......",
	"...eeTTTTTee....",
	"..eTTTTTTTTTe...",
	".eTTTTTTTTTTTe..",
	".TTTTTTTTTTTTT..",
	".KKKKKKKKKKKKK..",
	"................",
	"................",
	"................",
	"................",
]

const MOUNTAIN := [
	".......N........",
	"......NeN.......",
	".....NeTeN......",
	"....NeTTTeN.....",
	"...NeTTTTTeN....",
	"..NeTTtTTTTeN...",
	".NeTTTTTTTTTeN..",
	"NeTTTTTTTTTTTeN.",
	"eTTTTKKTTTTTTTe.",
	"TTTKKeTTTKKTTTT.",
	"TTTKKeTTTKKTTTT.",
	"TTTTTTTTTTTTTTT.",
	"KKKKKKKKKKKKKKK.",
	"................",
	"................",
	"................",
]

const TOWER_PROP := [
	"................",
	"....KcccccK.....",
	"...KcHHHHHcK....",
	"...KcHHHHHcK....",   # battlement flag pole (H repurposed? no - use y gold flag)
	"...KKKKKKKKK....",
	"....KtttttK.....",
	"....KtTTTtK.....",
	"....KtTTTtK.....",
	"....KtTTTtK.....",
	"....KtTTTtK.....",
	"....KtTTTtK.....",
	"....KtTTTtK.....",
	"...KKtTTTtKK....",
	"..KTTtTTTtTTK...",
	".KKTTKKKKKTTKK..",
	"KKKKKKKKKKKKKKK.",
]

const CASTLE := [
	"......y.........",   # pennant flags
	"......y.........",
	"....e.e.e.e.....",   # crenellated tower tops (e=light stone)
	"...eTTTeTTTe....",   # T=mid stone
	"...eTtteTTTte...",   # t=shaded stone
	"...eTtteKTTte...",   # K=arrow slits
	".e.eTtteKTTte.e.",   # outer wall crenellations
	"eTTTTTTeKTTTTTTe",
	"TtttTTTTTTTTtttT",
	"TtKkTTTTTTTTtKkT",   # arrow slits on wall (k reuse as slit shadow)
	"TtKkTTTKKTTTtKkT",   # gatehouse top (KK=dark gate arch start)
	"TtKkTTTKKTTTtKkT",
	"TtKkTTTnnTTTtKkT",   # raised portcullis (nn=wood/gate)
	"TtKkTTnmMMmnTtKk",   # open gate mouth (M=mossy wood)
	"KKKKKKKmMMmKKKKK",   # foundation
	"KKKKKKKKKKKKKKKK",
]


# ============================ TOWERS (story unlocks) ============================

const CROSSBOWMAN := [
	"................",
	"......y.........",   # hood quill
	".....yy.........",
	"....yYYy........",   # gold-trim hood
	"...yYYoYy....M..",   # face + bow stock
	"..yYYoooYy..Mm..",
	"..yYoooooy..Mm..",   # eyes + cocked bow
	"...yYooooy..Mm..",
	"....yAAAy...m...",   # shoulders + crossbow body
	"...AAyyyAA..m...",   # quarrels
	"...AyyyyyA..mZ..",   # bolt tip (Z)
	"....KyyyK...m...",
	"....Kmm.mK......",   # legs
	"...KKm...mK.....",
	"..KKKK...KKKK...",
	"................",
]

const FROST_MAGE := [
	"................",
	"......b.........",   # frost crystal tip
	".....bb.........",
	"....cbc.........",   # cyan-blue hood crown
	"...ccbc.........",
	"..ccccc.........",   # swept hood
	".cccccCC........",   # brim
	".cnnnnnc....b...",   # hair + ice staff orb
	".cnSSSnc....c...",   # face + staff
	".cnwwwnc....c...",   # frost beard
	".cnwwwnc....c...",
	"..cnnnnc....m...",   # robe + staff base
	"..ccmmcc....m...",
	"...KmmmK........",
	"...Km..mK.......",
	"...K....K.......",
]

const CATAPULT := [
	"................",
	"................",
	"...M............",   # throwing arm tip
	"..MM.....ZZ.....",   # arm + boulder (Z)
	".MMM....ZyZ.....",
	".MMmm..ZyyZ.....",   # arm joint + payload
	".MmmmmZZyyZ.....",
	"..mmMMMyyyZ.....",   # frame
	"...MMMMMMM......",
	"..MmmmmmM.......",   # bucket
	"..KKKKKKKK......",   # wheels
	".KK....KK.......",
	".KK....KK.......",
	"KKKK..KKKK......",
	"................",
	"................",
]

# ============================ TOWERS (extended arc, levels 7-12) ============================

# Cleric — white/gold priest, halo + holy mace. Splash dazzle support.
const CLERIC := [
	"................",
	".......z........",   # halo
	"......zzz.......",
	".....zzzzz......",
	"....wnwwwn......",   # hood
	"...nwwwwwwn.....",
	"...nwSSSwwn.w...",   # face + mace shaft
	"...nwKwKwwn.w...",   # eyes
	"...nwSSSwwn.w...",
	"....nwwwwn..w...",
	"...zzwwwwzz.Y...",   # gold-trim robe + mace head
	"..zwwwwwwwwz.Y..",
	"..zwwwwwwwwz.m..",
	"...KwwwwwwK.m...",
	"...Kmm..mmK.....",
	"..KKKK..KKKK....",
]

# Paladin — gold-trim plate armor + warhammer. Heavy holy frontline.
const PALADIN := [
	"................",
	"......y.........",   # plume
	"......y.........",
	"....KKiiiiKK....",   # helm
	"...KiiiiiiiiK...",
	"...KiIIIIIIiK...",   # visor
	"...KiAiiAiAik...",   # eyes
	"...KiiiiiiiiK...",
	"....KSSSSSSK....",   # chin
	"...AAyyyyyAA.Z..",   # shoulders + hammer head
	"..AyyyyyyyyyAZ..",   # gold chest plate + shaft
	"..AyyyyyyyyyAZ..",
	"..AyyyyyyyyyA...",
	"...KAyyyyyAK....",   # belt
	"....Kmm..mmK....",   # legs
	"...KKKK..KKKK...",
]

# Bard — purple hood + lute. Wide-slow crowd control.
const BARD := [
	"................",
	"......p.........",   # hood tip
	".....ppp........",
	"....ppppp.......",
	"...ppuuupp......",
	"..ppuuuuup......",   # hood
	"..Puuuuuup......",
	"..PnSSSSnP..u...",   # face + lute
	"..PuwnwwnP..u...",
	"...PnnnnP...u...",
	"...PPmmPP..uuu..",   # robe + lute body
	"..PmmmmmmP.uYuu.",   # lute strings
	"..PmmmmmmP.uuuu.",
	"...KmmmmK..uuu..",
	"...Km..mK.......",
	"..KKK..KKK......",
]

# Alchemist — green hood, lobbed flasks. Ranged splash over the front line.
const ALCHEMIST := [
	"................",
	"......q.........",   # hood tip
	".....gqg........",
	"....ggqgg.......",
	"...ggGgGgg......",   # hood
	"..ggGsssGg......",
	"..gGsKsKsGg..q..",   # eyes + flask
	"..gGsssssg..q...",
	"...gGSSSSg..g...",   # face + flask neck
	"...GGmmGG...y...",   # apron + flask body
	"..MmmGGmmM..g...",
	"..MmmmmmmM..y...",
	"...KmmmmK...g...",
	"...Km..mK.......",
	"..KKK..KKK......",
	"................",
]

# Prince — blue royal + crossbow. Fast accurate single shots, hits air.
const PRINCE := [
	"................",
	".....y.y.y......",   # crown
	"....KKKKKK......",
	"...KiiiiiiK.....",
	"...KiIIIIiK..M..",   # face + crossbow stock
	"...KiAiiAiK.Mm..",   # eyes
	"...KiiiiiiK.Mm..",
	"....KSSSSK..m...",   # chin
	"...bBccccBb.mZ..",   # royal shoulders + bolt
	"..bBBccccBBb.m..",   # blue tunic
	"..bBcccccBb.m...",
	"..bBcccccBb.m...",
	"...KBccccBK.....",
	"....Kmm.mmK.....",
	"...KKK..KKK.....",
	"................",
]

# Princess — pink gown + wand. Long-range enchanted bolts, slows on hit.
const PRINCESS := [
	"................",
	".....y.y.y......",   # crown
	"....KKKKKK......",
	"...KppppppK.....",
	"...KpSSSSpK..u..",   # face + wand orb
	"...KpAwWpK...p..",   # eyes
	"...KppppppK..p..",
	"....KSSSSK...p..",   # chin
	"...pppppppp..m..",   # dress shoulders
	"..ppuuuuuupp.m..",   # gown
	"..ppuuuuuupp.m..",
	"..pppuupppp.....",
	"...KpppppK......",
	"....Kmm.mK......",
	"...KKK..KKK.....",
	"................",
]

# ============================ ENEMIES (story unlocks) ============================

const CURSED_SKULL := [
	"................",
	"...PPPPPPPP.....",   # purple cursed crown
	"..PnnnnnnnnP....",
	".PnnKKnnKKnnP...",   # brow
	".PnddnnnnddnP...",   # eye sockets (glowing d)
	".PnKKnnnnKKnP...",
	".PnnnKKKKnnnP...",
	"..PnnKKKKnnnP...",   # teeth
	"...PnnnnnnP.....",
	"....PnnnnP......",
	"...PnWnWnP......",   # ribcage
	"...nnnnnn.......",
	"....KK.KK.......",
	"...nnn.nnn......",
	"..KKKK.KKKK.....",
	"................",
]

const WRAITH := [
	"................",
	"....PPPP........",   # hood crown
	"...PuuuuP.......",
	"..PuuuuuuP......",
	".PuKKuuKKuP.....",   # glowing eyes
	".PuuuuuuuuP.....",
	".PuCCuuCCuuP....",   # spectral face
	".PuuuuuuuuP.....",
	"..PuuuuuuP......",   # tattered cloak
	"..Pu.uu.uP......",
	"..Pu..u..uP.....",
	"..Pu......uP....",
	"..P........P....",
	".PP........PP...",
	"................",
	"................",
]

const HELLHOUND := [
	"................",
	".R..........R...",   # flame ears
	"rRR........RRr..",
	"rRRo......oRRr..",
	"rrRRrrrrrrRRrr..",   # head
	".rRKKrrrrKKRr...",   # brow
	".rRForrFoRrr....",   # fire eyes (F)
	".rrrommrrrr.....",   # snout
	".rrrKKmmKKrrr...",   # fangs
	"..rrrrrrrrrr....",
	"..RoRRRRRRoR....",   # flame mane down back
	".RoRRRRRRRRoR...",
	".Ro.rrrrrr.oR...",   # legs
	".KK.rr..rr.KK...",
	"KKKK....KKKK....",
	"................",
]

const BANSHEE := [
	"................",
	"....LLLL........",   # spectral crown
	"...LuuuuL.......",
	"..LuuuuuuL......",
	".LuKKuuKKuL.....",   # hollow glowing eyes
	".LuuuuuuuuL.....",
	".LuCCuuCCuuL....",   # screaming mouth
	".LuuuuuuuuL.....",
	".LuKKuuKKuuL....",
	".LuuuuuuuuL.....",
	"..LuuuuuuL......",
	"..Lu.uu.uL......",   # tattered wavy bottom
	"..Lu..u..uL.....",
	".Lu...u...uL....",
	".L.....L...L....",
	"................",
]

const HYDRA := [
	"................",
	".PP...PP...PP...",   # three horned heads
	"PPPP.PPPP.PPPP..",
	"PPuP.PPuP.PPuP..",
	"PPuP.PPuP.PPuP..",   # each head's eyes
	".PP..PPP..PP....",   # jaw line
	"..uPPuPPPuPPu...",   # fangs
	".PPPPPPPPPPPPP..",   # body confluence
	"PPuPPPuPPPuPPuPP",
	"PPPPPPPPPPPPPPPP",
	".PPPPPPPPPPPPP..",   # wings spread
	"uuPPPPPPPPPPuu..",
	".uuPPPPPPPPuu...",
	"..KPPPPPPPPK....",   # tail/legs
	"..KPP....PPK....",
	".KKKK....KKKK...",
]

# ============================ ENEMIES (extended arc, levels 7-12) ============================

# Vampire — black-cloaked regenerator with a high collar and red eyes.
const VAMPIRE := [
	"................",
	"....PPPP........",   # swept hair
	"...PuuuuP......",
	"..PuuuuuuP......",
	".PuKKuuKKuP.....",   # red eyes
	".PuuuuuuuuP.....",
	".PuCCuuCCuuP....",   # fanged mouth
	".PuuuuuuuuP.....",
	"..PuKKuuKKuP....",   # collar bones
	".PPuuuuuuPP.....",
	".PPuuuuuuPP.....",
	"..PuuuuuuP......",   # cloak
	"..P.uu.uu.P.....",
	"..P......P......",
	".PP......PP.....",
	"................",
]

# Zombie — green-skinned corpse, tattered, one eye glowing.
const ZOMBIE := [
	"................",
	"................",
	"....HHHHHH......",
	"...HhhhHHhH.....",   # lopsided head
	"..HhhKhhhKhh....",   # eyes (one dark, one socket)
	"..HhhhFhhhhhh...",   # one glowing eye
	"..Hhhhhhhhhh....",
	"...HhKKKKHh.....",   # broken teeth
	"....HnnnnH......",
	"...nnWnnWnn.....",   # exposed ribs
	"...nnnnnnnn.....",
	"....Hn..nH......",
	"...HHH..HHH.....",
	"..HH......HH....",
	"................",
	"................",
]

# Mummy — bandaged undead, wrapped in off-white strips with amber trim.
const MUMMY := [
	"................",
	"....nnnnnn......",
	"...nnnnnnnn.....",
	"..nnKKnnKKnn....",   # brow
	"..nddnnnnddn....",   # eye sockets
	"..nnKKnnKKnn....",
	"...nnKKKKnn.....",   # mouth wrap
	"....nnnnnn......",
	"...WnWWWWnW.....",   # crossed bandages
	"..WWnWnnWnWW....",
	"..WnWWWWWWnW....",
	"..WWnWnnWnWW....",
	"...WnWWWWnW.....",
	"...yy....yy.....",   # tattered legs
	"..yyy....yyy....",
	"................",
]

# Orc — green-skinned warrior with a heavy brow and tusks.
const ORC := [
	"................",
	"................",
	"...Hh......hH...",
	"..HHHh....hHHH..",
	".HHhHHhhhhHHhH..",
	".HhKKKhhhhKKKhH.",   # heavy brow
	".HhhRrhRRhrRhhH.",   # eyes
	".HhhhmmmmhhhhH..",   # flat snout
	".HhhKKmmKKhhhh..",   # tusks
	"..HhhhhhhhhhH...",
	"..HHhhhhhhhHH...",
	"...Hhh....hhH...",   # arms
	"...HH......HH...",
	"..HHHH....HHHH..",
	"................",
	"................",
]

# Witch — pointed hat + broom. Flying hexer.
const WITCH := [
	"....P...........",   # hat tip
	"...PP...........",
	"..PPP...........",
	".PPPP...........",
	"PPPPP...........",   # brim
	".PuSSuP.........",   # face under hat
	".PuCCuP.....m...",   # eyes + broom shaft
	".PuuuuP.....m...",
	".PuCCuP.....m...",
	"..PuuP......M...",   # broom bristles
	"..PmmP......M...",
	"..PmmP......M...",
	"..PmmP......M...",
	"..PmmP......m...",
	".PPPPPP.....mm..",
	"................",
]

# Gargoyle — stone winged sentinel. Heavy, armored, flying.
const GARGOYLE := [
	"TT...........TT.",   # horn tips
	"TTT.........TTT.",
	"eTTT.......TTTe.",
	"eTTTT.....TTTTe.",   # horns curving in
	"eTTTTTT.TTTTTTe.",
	".eTTKTTTTKTTTe..",   # glowing stone eyes
	".eTTTTTTTTTTe...",
	"..eTTKKKTTTe....",   # fanged mouth
	"...eTTTTTe......",
	"TeTTTTTTTTeT....",   # folded wings
	"TTeeTTTTTeeTT...",
	"TTT.eTTTTe.TTT..",
	".TT..eTTTe..TT..",
	"..T...eTe...T...",
	"......KK........",
	".....KKKK.......",
]

# Demon Lord — colossal winged horned tyrant. The finale boss.
const DEMON_LORD := [
	".RR..........RR.",   # great horns
	"RRRR........RRRR",
	"RRrR........RrRR",
	"RRRRR......RRRRR",
	"RrRRRoroorRRRrRR",   # brow + inner fire
	"RRRRoFFFFoRRRR..",   # fire eyes
	".RRRRooooRRRR...",   # snout
	"..RRKKKKKKRR....",   # fanged maw
	"...RRRRRRRR.....",
	"RrRRRRRRRRRRRrR.",   # spread wings
	"RRRRRRRRRRRRRRR.",
	".RRRRRRRRRRRRR..",
	"..rRRRRRRRRRr...",
	"...RRRRRRRR.....",
	"...KK......KK...",   # clawed legs
	"..KKKK....KKKK..",
]


# ============================ DISPATCH ============================


static func for_unit(unit_id: String) -> PackedStringArray:
	match unit_id:
		&"soldier":     return SOLDIER
		&"archer":      return ARCHER
		&"knight":      return KNIGHT
		&"wizard":      return WIZARD
		&"crossbowman": return CROSSBOWMAN
		&"frost_mage":  return FROST_MAGE
		&"catapult":    return CATAPULT
		&"cleric":      return CLERIC
		&"paladin":     return PALADIN
		&"bard":        return BARD
		&"alchemist":   return ALCHEMIST
		&"prince":      return PRINCE
		&"princess":    return PRINCESS
	return SOLDIER


## Directional + stance sprite for a defender.
## `facing` is one of DIR_FRONT / DIR_BACK / DIR_LEFT / DIR_RIGHT.
## `attacking` selects the attack pose (true) or idle pose (false).
##
## LEFT is always rendered as the RIGHT grid flipped horizontally by the caller,
## so this returns the SIDE grid for both LEFT and RIGHT.
##
## Units that don't yet have directional art (everything except the soldier for
## now) fall back to their single canonical sprite — the game keeps working
## unchanged until you add their grids below.
static func for_unit_dir(unit_id: String, facing: String, attacking: bool) -> PackedStringArray:
	match unit_id:
		&"soldier":
			# LEFT uses the same SIDE grids as RIGHT — the caller flips the sprite.
			match facing:
				DIR_FRONT:
					return SOLDIER_FRONT_ATTACK if attacking else SOLDIER_FRONT_IDLE
				DIR_BACK:
					return SOLDIER_BACK_ATTACK if attacking else SOLDIER_BACK_IDLE
				DIR_LEFT, DIR_RIGHT:
					return SOLDIER_SIDE_ATTACK if attacking else SOLDIER_SIDE_IDLE
				_:
					return SOLDIER_FRONT_IDLE
	# Graceful fallback: units without directional art render their single grid
	# in every facing/stance so nothing breaks.
	return for_unit(unit_id)


## Directional + stance TEXTURE for a texture-art unit (soldier, archer, knight,
## wizard, crossbowman, cleric, bard, catapult).
## Returns the Texture2D to draw and, via the returned Dictionary, whether the
## caller should mirror it horizontally (`flip_h`). For all these units the side
## art faces LEFT, so RIGHT is returned with flip_h = true.
##
## Only call this when has_texture_art(unit_id) is true; for other units use
## for_unit_dir() (ASCII grid).
static func for_unit_dir_texture(unit_id: String, facing: String, attacking: bool) -> Dictionary:
	# Default: no horizontal flip (front/back/left art is drawn as-is).
	var flip := false
	var tex: Texture2D

	match unit_id:
		&"soldier":
			tex = _soldier_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"archer":
			tex = _archer_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"knight":
			tex = _knight_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"wizard":
			tex = _wizard_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"crossbowman":
			tex = _crossbowman_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"cleric":
			tex = _cleric_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"bard":
			tex = _bard_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		&"catapult":
			tex = _catapult_tex(facing, attacking)
			if facing == DIR_RIGHT:
				flip = SIDE_FLIP_FOR_RIGHT
		_:
			tex = SOLDIER_TEX_FRONT_IDLE

	return {
		&"texture": tex,
		&"flip_h": flip,
		&"size": SOLDIER_DRAW_SIZE,
	}


static func for_enemy(enemy_id: String) -> PackedStringArray:
	match enemy_id:
		&"goblin":       return GOBLIN
		&"skeleton":     return SKELETON
		&"ghost":        return GHOST
		&"bat":          return BAT
		&"wolf":         return WOLF
		&"demon":        return DEMON
		&"troll":        return TROLL
		&"dragon":       return DRAGON
		&"cursed_skull": return CURSED_SKULL
		&"wraith":       return WRAITH
		&"hellhound":    return HELLHOUND
		&"banshee":      return BANSHEE
		&"hydra":        return HYDRA
		&"vampire":      return VAMPIRE
		&"zombie":       return ZOMBIE
		&"mummy":        return MUMMY
		&"orc":          return ORC
		&"witch":        return WITCH
		&"gargoyle":     return GARGOYLE
		&"demon_lord":   return DEMON_LORD
	return GOBLIN


static func for_prop(prop_id: String) -> PackedStringArray:
	match prop_id:
		&"tree":     return TREE
		&"rock":     return ROCK
		&"mountain": return MOUNTAIN
		&"tower":    return TOWER_PROP
		&"castle":   return CASTLE
	return ROCK
