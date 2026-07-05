extends Node2D
## PropsLayer: renders decorative pixel-art props (trees, mountains, watchtowers,
## castle) on top of the GameWorld's biome floor.
##
## Which prop goes where is driven by the world's biome map (forest -> trees,
## mountain -> mountains), so PropsLayer stays in sync with buildability. The
## castle at the goal is also placed here as the visual thing the player defends.
##
## Drawn UNDER towers but ON TOP of enemies (enemies are children of GameWorld),
## so large props like the castle visually cover enemies passing beneath them —
## which is exactly the "entering the castle" read we want at the goal.

const TILE := 26

# Each prop: { id, tile, scale, oy }. scale = per-pixel size of the ASCII art;
# oy = vertical nudge to ground the sprite.
var _props: Array = []

var _world: Node2D = null


func _ready() -> void:
	# GameWorld is our sibling in Main; grab it once for biome lookups.
	_world = get_parent().get_node_or_null("GameWorld")
	_lay_out_props()


func _lay_out_props() -> void:
	_props.clear()
	if _world == null or not _world.has_method("biome_at"):
		return
	# Deterministic scatter so each run is identical (stable, no shimmer).
	# Forest tiles get a dense tree canopy; mountain tiles get rocky peaks.
	for y in _world.ROWS:
		for x in _world.COLS:
			var t := Vector2i(x, y)
			var b: StringName = _world.biome_at(t)
			var h := _hash(x, y)
			match b:
				_world.BIOME_FOREST:
					# ~70% of forest tiles carry a tree so regions read as woods
					# but with breathing gaps (not a solid wall of trunks).
					if (h & 0xFF) < 178:
						var scale := 1.5 + float((h >> 8) & 0x3F) / 0x3F * 0.5   # 1.5..2.0
						var oy := 2 + ((h >> 16) & 0x3)   # tiny grounding nudge
						_props.append({ &"id": &"tree", &"tile": t, &"scale": scale, &"oy": oy })
				_world.BIOME_MOUNTAIN:
					# Every mountain tile gets a peak; vary size so ridges roll.
					var scale := 2.0 + float((h >> 8) & 0x3F) / 0x3F * 0.8   # 2.0..2.8
					var oy := 6 + ((h >> 16) & 0x3)
					_props.append({ &"id": &"mountain", &"tile": t, &"scale": scale, &"oy": oy })
				_:
					pass
	# A few watchtower accents near path corners — only on non-grass tiles so we
	# never steal prime build space. Hand-picked spots that fall on forest/mountain.
	for t in [Vector2i(4, 0), Vector2i(27, 16), Vector2i(20, 0)]:
		if _world.biome_at(t) != _world.BIOME_GRASS:
			_props.append({ &"id": &"tower", &"tile": t, &"scale": 1.75, &"oy": 5 })
	# THE GOAL: a prominent castle straddling the path exit on the right edge.
	# Centred on the 2x2 castle footprint (cols 30-31, rows 10-11) so the road
	# runs straight into the gate — enemies visibly march up to and enter it.
	_props.append({ &"id": &"castle", &"tile": Vector2i(30, 10), &"scale": 4.0, &"oy": 16 })


func _hash(x: int, y: int) -> int:
	var h := (x * 73856093) ^ (y * 19349663)
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h)


func _draw() -> void:
	for prop in _props:
		_draw_prop(prop)


func _draw_prop(prop: Dictionary) -> void:
	var pid: String = prop.id
	var pattern: PackedStringArray = PixelArt.for_prop(pid)
	var pal: Dictionary = PixelArt.PALETTE
	var psize: float = prop.scale
	# World position: tile center + map origin + vertical offset for grounding.
	var o: Vector2 = _world.get("map_origin") if (_world and _world.get("map_origin") != null) else Vector2.ZERO
	var center := o + Vector2(prop.tile.x * TILE + TILE * 0.5, prop.tile.y * TILE + TILE * 0.5 + prop.oy)
	var height := pattern.size()
	var width := 0
	for row in pattern:
		width = maxi(width, row.length())
	var origin := center - Vector2(width, height) * psize * 0.5
	for y in range(height):
		var row: String = pattern[y]
		for x in range(row.length()):
			var ch := row[x]
			if ch == " " or ch == ".":
				continue
			var key := String(ch)
			if not pal.has(key):
				continue
			var rect := Rect2(origin + Vector2(x, y) * psize, Vector2(psize, psize))
			draw_rect(rect, pal[key])
