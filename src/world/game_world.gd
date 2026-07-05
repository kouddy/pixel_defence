extends Node2D
## GameWorld: holds the enemy path, draws the map, manages tower placement.
##
## The playfield is divided into biomes (grass/water/forest/mountain/path/castle).
## Only grass tiles are buildable. The path is a list of waypoints; enemies walk
## from path[0] to path[-1].

const TILE := 26
const COLS := 32
const ROWS := 18

# Biome identifiers (StringName for cheap dict keys + fast comparison).
const BIOME_GRASS := &"grass"
const BIOME_WATER := &"water"
const BIOME_FOREST := &"forest"
const BIOME_MOUNTAIN := &"mountain"
const BIOME_PATH := &"path"
const BIOME_CASTLE := &"castle"

# Landscape (16:9) S-curve path: enemies flow LEFT -> RIGHT with vertical
# switchbacks so towers get long edges to cover. Coordinates are tile (col,row);
# top-left is (0,0). Spawn is off the left edge at col -2.
const PATH_TILES := [
	Vector2i(-2, 2),   # spawn (off the left edge)
	Vector2i(6, 2),    # run right along row 2
	Vector2i(6, 8),    # drop down to row 8
	Vector2i(25, 8),   # long run right along row 8 (mid map)
	Vector2i(25, 14),  # drop to row 14
	Vector2i(13, 14),  # run LEFT back across (switchback)
	Vector2i(13, 11),  # rise to row 11
	Vector2i(28, 11),  # final long run right toward the goal
	Vector2i(30, 11),  # exit into the castle gate
]

# Castle footprint at the goal: a 2x2 block straddling the path exit on the
# right edge, so the road runs into the castle gate (the visual objective).
const CASTLE_TILES := [
	Vector2i(30, 10), Vector2i(31, 10),
	Vector2i(30, 11), Vector2i(31, 11),
]

var path_points: Array[Vector2] = []   # world-space waypoints
var occupied: Dictionary = {}          # Vector2i -> bool (built-on tiles)
# Vector2i -> StringName biome. Source of truth for buildability + ground draw.
var _biome: Dictionary = {}
# Top-left pixel of the playfield. Computed in _ready so the map sits below the
# HUD top bar and is centred in the remaining viewport space.
var map_origin := Vector2.ZERO

@onready var build_hint: ColorRect = $BuildHint


func _ready() -> void:
	# The viewport is sized to the map (COLS*TILE x ROWS*TILE), so the map
	# fills the whole screen with origin at the top-left corner. The HUD floats
	# on top as a transparent overlay.
	map_origin = Vector2.ZERO
	_rebuild_path()
	_generate_biomes()
	_draw_map()
	if build_hint:
		build_hint.visible = false


func _rebuild_path() -> void:
	path_points.clear()
	for t in PATH_TILES:
		path_points.append(tile_to_world(t))


# ============================ BIOME MAP ============================

## Generate the biome map once. Deterministic value noise carves blobby regions
## of water/forest/mountain, then path/castle/grass-buffer overrides fix the
## gameplay-critical tiles. The map is identical every run (no shimmer, stable
## buildability).
func _generate_biomes() -> void:
	_biome.clear()
	for y in ROWS:
		for x in COLS:
			var t := Vector2i(x, y)
			var v := _smooth_noise(float(x), float(y))
			var b: StringName
			if v < 0.33:
				b = BIOME_WATER
			elif v < 0.55:
				b = BIOME_GRASS
			elif v < 0.72:
				b = BIOME_FOREST
			else:
				b = BIOME_MOUNTAIN
			_biome[t] = b
	# Overrides: path and castle must win over whatever the noise produced.
	for y in ROWS:
		for x in COLS:
			var t := Vector2i(x, y)
			if is_path_tile(t):
				_biome[t] = BIOME_PATH
	for t in CASTLE_TILES:
		if _biome.has(t):
			_biome[t] = BIOME_CASTLE
	# Grass buffer: every tile adjacent (8-neighbourhood) to the path becomes
	# grass so towers can always flank the road — essential for a TD.
	for y in ROWS:
		for x in COLS:
			var t := Vector2i(x, y)
			if _biome[t] == BIOME_PATH:
				continue
			if _has_path_neighbour(t):
				_biome[t] = BIOME_GRASS
	# Keep a guaranteed buildable pocket of grass in the open mid-area for the
	# player's first towers (in case noise + buffer leave a tight start).
	_ensure_grass_pockets()


func _has_path_neighbour(t: Vector2i) -> bool:
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nt := Vector2i(t.x + dx, t.y + dy)
			if _biome.get(nt, BIOME_GRASS) == BIOME_PATH:
				return true
	return false


# Reserve a few clusters of grass next to path bends so the early game always
# has prime tower spots regardless of how the noise fell.
func _ensure_grass_pockets() -> void:
	# Anchor tiles near each horizontal run of the path; flatten a 3x3 around
	# them to grass if they're currently blocking features.
	var anchors := [
		Vector2i(3, 4),    # above the first horizontal run (row 2)
		Vector2i(15, 5),   # between the row-2 and row-8 runs (open mid-top)
		Vector2i(20, 9),   # just under the row-8 long run / switchback area
		Vector2i(22, 13),  # beside the bottom run approaching the goal
	]
	for a in anchors:
		for dy in [-1, 0, 1]:
			for dx in [-2, -1, 0, 1, 2]:
				var t := Vector2i(a.x + dx, a.y + dy)
				if not _biome.has(t):
					continue
				if _biome[t] == BIOME_PATH or _biome[t] == BIOME_CASTLE:
					continue
				_biome[t] = BIOME_GRASS


## One-octave smoothly-interpolated value noise. Coarse grid (~7 cells across
## the map) so regions blob together into coherent features rather than static.
func _smooth_noise(x: float, y: float) -> float:
	const FREQ := 0.16
	const SEED := 1337.0
	var gx := x * FREQ
	var gy := y * FREQ
	var x0 := floori(gx)
	var y0 := floori(gy)
	var fx := smoothstep(0.0, 1.0, gx - x0)
	var fy := smoothstep(0.0, 1.0, gy - y0)
	var v00 := _hash01(x0, y0, SEED)
	var v10 := _hash01(x0 + 1, y0, SEED)
	var v01 := _hash01(x0, y0 + 1, SEED)
	var v11 := _hash01(x0 + 1, y0 + 1, SEED)
	var a := lerpf(v00, v10, fx)
	var b := lerpf(v01, v11, fx)
	return lerpf(a, b, fy)


func _hash01(ix: int, iy: int, seed: float) -> float:
	# Deterministic pseudo-random in [0,1) from integer coords. Two large primes
	# + an FNV-ish multiply; good enough for region shapes.
	var h := (ix * 73856093) ^ (iy * 19349663) ^ int(seed * 65537.0)
	h = (h ^ (h >> 13)) * 1274126177
	# absi avoids Godot's differing int/uint division behaviour on negatives.
	return float(absi(h) & 0xFFFFFF) / float(0xFFFFFF)


## Public lookup used by PropsLayer (rendering) and can_build_at (gameplay).
func biome_at(t: Vector2i) -> StringName:
	if t.x < 0 or t.x >= COLS or t.y < 0 or t.y >= ROWS:
		return BIOME_GRASS
	return _biome.get(t, BIOME_GRASS)


# ============================ COORDS ============================

func tile_to_world(t: Vector2i) -> Vector2:
	return map_origin + Vector2(t.x * TILE + TILE * 0.5, t.y * TILE + TILE * 0.5)


func world_to_tile(p: Vector2) -> Vector2i:
	var local_p := p - map_origin
	return Vector2i(floori(local_p.x / TILE), floori(local_p.y / TILE))


func is_path_tile(t: Vector2i) -> bool:
	# A tile is "on the path" if it lies between two consecutive path waypoints
	# along either a horizontal or vertical segment.
	for i in range(PATH_TILES.size() - 1):
		var a: Vector2i = PATH_TILES[i]
		var b: Vector2i = PATH_TILES[i + 1]
		var min_x := mini(a.x, b.x)
		var max_x := maxi(a.x, b.x)
		var min_y := mini(a.y, b.y)
		var max_y := maxi(a.y, b.y)
		if t.x >= min_x and t.x <= max_x and t.y >= min_y and t.y <= max_y:
			return true
	return false


func can_build_at(p: Vector2) -> bool:
	var t := world_to_tile(p)
	if t.x < 0 or t.x >= COLS or t.y < 0 or t.y >= ROWS:
		return false
	# Only open grass is buildable; water/forest/mountain/path/castle all block.
	if biome_at(t) != BIOME_GRASS:
		return false
	if occupied.has(t):
		return false
	return true


func occupy(p: Vector2) -> Vector2i:
	var t := world_to_tile(p)
	occupied[t] = true
	return t


## Position snapped to the centre of a tile (where towers get placed).
func snapped_center(p: Vector2) -> Vector2:
	var t := world_to_tile(p)
	return tile_to_world(t)


func show_build_hint(p: Vector2, ok: bool) -> void:
	if not build_hint:
		return
	var center := snapped_center(p)
	build_hint.position = center - Vector2(TILE * 0.5, TILE * 0.5)
	build_hint.size = Vector2(TILE, TILE)
	build_hint.color = Color(0.2, 0.9, 0.3, 0.35) if ok else Color(0.9, 0.2, 0.2, 0.35)
	build_hint.visible = true


func hide_build_hint() -> void:
	if build_hint:
		build_hint.visible = false


## Total path length in pixels (for enemy progress tracking).
func path_length() -> float:
	var total := 0.0
	for i in range(1, path_points.size()):
		total += path_points[i].distance_to(path_points[i - 1])
	return total


func _draw_map() -> void:
	queue_redraw()


func _draw() -> void:
	# 1. Backdrop: sky gradient + distant hills, drawn first so everything else
	#    sits on top. This fills the area around/above the playfield.
	_draw_backdrop()
	# 2. Playfield ground tiles — drawn per-biome. Trees/mountains sit on top of
	#    their floor in PropsLayer; here we paint each tile's ground colour.
	for y in ROWS:
		for x in COLS:
			var t := Vector2i(x, y)
			var b: StringName = _biome.get(t, BIOME_GRASS)
			var rect := Rect2(map_origin.x + x * TILE, map_origin.y + y * TILE, TILE, TILE)
			var dark := (x + y) % 2 == 0
			match b:
				BIOME_WATER:
					_draw_water(rect, x, y)
				BIOME_FOREST:
					# Darker, mossy floor under the canopy; solid, no speckles.
					draw_rect(rect, Color(0.30, 0.50, 0.20))
				BIOME_MOUNTAIN:
					_draw_mountain_floor(rect, x, y, dark)
				BIOME_PATH:
					# Path cobblestones are painted in the dedicated pass below.
					draw_rect(rect, Color(0.12, 0.16, 0.12))
				BIOME_CASTLE:
					# Grass base under the castle footprint; the prop is in PropsLayer.
					draw_rect(rect, Color(0.42, 0.62, 0.30))
				_:
					# Grass: solid bright green, no detail marks.
					var ground := Color(0.42, 0.62, 0.30)
					draw_rect(rect, ground)
	# 3. Soft warm glow under the path so the route reads as "lit" and inviting.
	_draw_path_glow()
	# 4. Road: one continuous smooth strip along the waypoints, with rounded
	#    joints at corners. Replaces the old per-tile cobblestone grid, which
	#    read as a noisy checkerboard with seams at every tile boundary.
	_draw_road()
	# 5. Flow arrows so the route direction is obvious at a glance.
	_draw_path_arrows()
	# 6. Spawn portal (glowing green). The goal is the castle (drawn by PropsLayer).
	_draw_spawn_portal(path_points[0])


## Continuous smooth road drawn along path_points. A dark edge strip, a lighter
## sand fill, and round caps at every waypoint so 90° corners flow as one road
## instead of a blocky tile grid. Sparse texture flecks are scattered along the
## centerline — not a per-tile pattern — so the surface reads as worn stone
## without visible tile seams.
func _draw_road() -> void:
	if path_points.size() < 2:
		return
	var edge_w := float(TILE)            # outer dark border
	var fill_w := float(TILE - 6)        # inner driving surface
	var edge_col := Color(0.30, 0.24, 0.18)
	var fill_col := Color(0.74, 0.64, 0.44)
	# 1. Edge strip (widest) — the road's dark outline / raised curb.
	_draw_road_strip(path_points, edge_w, edge_col)
	# 2. Fill strip (narrower) — the warm sand-coloured surface on top.
	_draw_road_strip(path_points, fill_w, fill_col)
	# 3. Sparse cobble flecks along the centerline for texture. Hashed from the
	#    segment index + a per-stone counter so they're deterministic but don't
	#    line up with tile boundaries.
	for i in range(1, path_points.size()):
		var a: Vector2 = path_points[i - 1]
		var b: Vector2 = path_points[i]
		var dir: Vector2 = (b - a)
		var seg_len: float = dir.length()
		if seg_len < 1.0:
			continue
		var d := dir / seg_len
		var perp := Vector2(-d.y, d.x)
		var n_stones := int(seg_len / 9.0)
		for s in range(n_stones):
			var h := (i * 73856093) ^ (s * 19349663)
			var along: float = (float(s) + 0.5) * (seg_len / float(maxi(1, n_stones)))
			var jitter_a: float = float((h & 0x7) - 3)           # ±3px along
			var jitter_p: float = float(((h >> 3) & 0x7) - 3)    # ±3px across
			var col_var := 1.0 + (((h >> 6) & 0xF) / 0xF - 0.5) * 0.18
			var p: Vector2 = a + d * along + d * jitter_a + perp * jitter_p
			var sc := Color(clamp(fill_col.r * col_var, 0.0, 1.0),
					clamp(fill_col.g * col_var, 0.0, 1.0),
					clamp(fill_col.b * col_var, 0.0, 1.0), 0.9)
			draw_rect(Rect2(p - Vector2(1.5, 1.5), Vector2(3, 3)), sc)


## Draw `points` as a thick continuous strip: axis-aligned filled rects per
## segment (the path only turns at 90° because it follows tile centers) plus a
## filled circle at every waypoint to round the joints and cap the ends.
func _draw_road_strip(points: Array[Vector2], width: float, col: Color) -> void:
	var half := width * 0.5
	for i in range(1, points.size()):
		var a: Vector2 = points[i - 1]
		var b: Vector2 = points[i]
		var d := b - a
		if absf(d.x) > 0.5:
			# Horizontal segment.
			var x0 := minf(a.x, b.x) - half
			var x1 := maxf(a.x, b.x) + half
			draw_rect(Rect2(x0, a.y - half, x1 - x0, width), col)
		else:
			# Vertical segment.
			var y0 := minf(a.y, b.y) - half
			var y1 := maxf(a.y, b.y) + half
			draw_rect(Rect2(a.x - half, y0, width, y1 - y0), col)
	# Round joints + end caps so corners flow and the strip never shows a seam.
	for p in points:
		draw_circle(p, half, col)


## Rocky gray-brown floor for mountain tiles, with hashed stone flecks so it
## reads as scree rather than flat colour.
func _draw_mountain_floor(rect: Rect2, x: int, y: int, dark: bool) -> void:
	var base := Color(0.46, 0.42, 0.38) if dark else Color(0.52, 0.48, 0.44)
	draw_rect(rect, base)
	var h := (x * 73856093) ^ (y * 19349663)
	var n := (h % 3) + 2
	var fleck := Color(0.36, 0.33, 0.30, 0.7)
	for i in n:
		var hx := (h >> (i * 3)) & 0x3FF
		var hy := (h >> (i * 3 + 10)) & 0x3FF
		var px := rect.position.x + 3 + (hx % int(rect.size.x - 8))
		var py := rect.position.y + 3 + (hy % int(rect.size.y - 8))
		draw_rect(Rect2(px, py, 3, 3), fleck)


func _draw_backdrop() -> void:
	# Sky gradient + hills fill the entire viewport around the playfield so there
	# are no dead black margins. Heights anchor to the playfield's real top/bottom.
	var vp := get_viewport_rect().size
	var field_top := map_origin.y
	var field_bottom := map_origin.y + ROWS * TILE
	# Fill the whole viewport first with the deepest sky tone (covers the area
	# above the gradient + any thin side/bottom gaps).
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.16, 0.18, 0.26))
	# Sky gradient from deep dusk (top of viewport) to warm horizon (field_top).
	var steps := 24
	var horizon := Color(0.55, 0.50, 0.52)
	var dusk := Color(0.25, 0.30, 0.45)
	for i in steps:
		var t := float(i) / steps
		var c := dusk.lerp(horizon, t)
		var y0 := t * field_top
		var y1 := (float(i + 1) / steps) * field_top
		draw_rect(Rect2(0, y0, vp.x, y1 - y0 + 1), c)
	# Dark earth below the playfield.
	if field_bottom < vp.y:
		draw_rect(Rect2(0, field_bottom, vp.x, vp.y - field_bottom), Color(0.16, 0.14, 0.16))


func _draw_water(rect: Rect2, x: int, y: int) -> void:
	# Layered blues + a deterministic ripple highlight so water reads as water.
	draw_rect(rect, Color(0.22, 0.40, 0.62))
	var inset := Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8))
	draw_rect(inset, Color(0.30, 0.52, 0.74))
	# A couple of lighter ripple dashes, hashed from tile coords.
	var h := (x * 73856093) ^ (y * 19349663)
	for i in 2:
		var hx := (h >> (i * 5)) & 0x3FF
		var hy := (h >> (i * 5 + 9)) & 0x3FF
		var px := rect.position.x + 8 + (hx % int(rect.size.x - 20))
		var py := rect.position.y + 10 + (hy % int(rect.size.y - 24))
		draw_rect(Rect2(px, py, 10, 2), Color(0.45, 0.65, 0.90, 0.6))


func _draw_path_glow() -> void:
	# A soft warm halo drawn under the whole path, wide and low-alpha.
	for i in range(1, path_points.size()):
		var a: Vector2 = path_points[i - 1]
		var b: Vector2 = path_points[i]
		# Thicken by drawing a few parallel offset lines.
		var perp := Vector2(-(b - a).y, (b - a).x).normalized()
		for off in [-11.0, -5.0, 0.0, 5.0, 11.0]:
			draw_line(a + perp * off, b + perp * off,
					Color(1.0, 0.78, 0.40, 0.06), 6.0)


func _draw_path_arrows() -> void:
	# Draw a small chevron every ~2 tiles along each segment, pointing forward.
	var arrow_col := Color(1.0, 0.92, 0.55, 0.7)
	for i in range(1, path_points.size()):
		var a: Vector2 = path_points[i - 1]
		var b: Vector2 = path_points[i]
		var seg: Vector2 = b - a
		var len := seg.length()
		if len < TILE:
			continue
		var dir := seg.normalized()
		var steps := int(len / (TILE * 1.5))
		for s in range(1, steps + 1):
			var p := a + dir * (TILE * 1.5 * s)
			_draw_chevron(p, dir, arrow_col)


func _draw_chevron(p: Vector2, dir: Vector2, col: Color) -> void:
	# A small ">" oriented along dir.
	var perp := Vector2(-dir.y, dir.x)
	var tip := p + dir * 4
	var w1 := p - dir * 3 + perp * 3.5
	var w2 := p - dir * 3 - perp * 3.5
	draw_colored_polygon(PackedVector2Array([tip, w1, w2]), col)


func _draw_spawn_portal(p: Vector2) -> void:
	# Glowing ring + inner swirl: enemies "emerge" here. Drawn with a stronger
	# glow now that the map is busier, so it stays a clear focal point.
	var outer := Color(0.30, 0.85, 0.40, 0.4)
	var mid := Color(0.45, 0.95, 0.50, 0.75)
	var inner := Color(0.80, 1.0, 0.85, 0.95)
	draw_circle(p, TILE * 0.46, outer)
	draw_circle(p, TILE * 0.34, mid)
	draw_circle(p, TILE * 0.20, inner)
	# Slow rotation arc for "portal energy".
	draw_arc(p, TILE * 0.40, 0, TAU, 36, Color(0.6, 1.0, 0.7, 0.5), 2.0)

