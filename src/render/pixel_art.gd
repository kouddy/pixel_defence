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

# ============================ DEFENDERS ============================

const SOLDIER := [
	"................",
	"......I.........",   # helmet plume
	"......I.........",
	"....KKiiiiKK....",   # steel helmet
	"...KiiiiiiiiK...",
	"...KiIIIIIIiK...",   # visor
	"...KiIiiiiIiK...",   # eye slits
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
	return SOLDIER


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
	return GOBLIN


static func for_prop(prop_id: String) -> PackedStringArray:
	match prop_id:
		&"tree":     return TREE
		&"rock":     return ROCK
		&"mountain": return MOUNTAIN
		&"tower":    return TOWER_PROP
		&"castle":   return CASTLE
	return ROCK
