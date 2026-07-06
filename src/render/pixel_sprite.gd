extends Node2D
## PixelSprite: renders a small pixel-art sprite from an ASCII grid.
## Each character in `pattern` maps to a Color via `palette`.
## ' ' and '.' are transparent. Drawn via _draw() so it stays crisp at any zoom.
##
## Texture mode: instead of an ASCII grid, the sprite can render a single
## Texture2D (e.g. an imported SVG). Set via configure_texture(); the node then
## switches to drawing the texture, centred on the node origin. Texture mode is
## used by units that have detailed vector art (the soldier), while grid mode
## remains for everything else.
class_name PixelSprite

@export var pattern: PackedStringArray = PackedStringArray()
@export var palette: Dictionary = {}   # String (1 char) -> Color
@export var pixel_size: float = 4.0
@export var centered: bool = true
@export var outline_color: Color = Color(0.05, 0.04, 0.03, 1)
## Mirror the sprite horizontally. Used for left-facing characters so a single
## "right-facing" pattern set covers both sides. Kept here (not as scale.x = -1)
## so it never clashes with the recoil/upgrade scale tweens on this node.
var flip_h: bool = false

# --- texture mode state ---
# When non-null, _draw() renders the texture (centred) instead of the grid.
var _texture: Texture2D = null
# Draw size of the texture in pixels (square; SVG art is square). Sized so the
# art occupies roughly the same footprint as a 16-row grid at pixel_size.
var _texture_size: float = 32.0


func _ready() -> void:
	queue_redraw()


func configure(pat: PackedStringArray, pal: Dictionary, psize: float) -> void:
	pattern = pat
	palette = pal
	pixel_size = psize
	_texture = null   # a grid configure() exits texture mode
	# Grid art is hand-placed pixel blocks: keep nearest filtering so it stays
	# crisp under the project's global nearest filter.
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


## Render `tex` instead of the ASCII grid. `draw_size` is the on-screen edge
## length in pixels (square art). Keeps flip_h so the caller can still mirror
## horizontally for the opposite facing.
func configure_texture(tex: Texture2D, draw_size: float) -> void:
	_texture = tex
	_texture_size = draw_size
	# Detailed SVG art downscales cleanly with linear filtering; the project's
	# global default is nearest, which would alias the shading.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	queue_redraw()


## Toggle horizontal mirroring and redraw. Use this rather than setting flip_h
## directly so the change is reflected immediately.
func set_flip_h(v: bool) -> void:
	if flip_h == v:
		return
	flip_h = v
	queue_redraw()


func _draw() -> void:
	if _texture != null:
		# Texture mode: draw the art centred on the origin. Horizontal mirror is
		# done via a draw-time transform (negative x scale), NOT the node's scale
		# property — that one is animated by recoil/upgrade tweens and must stay
		# positive. draw_set_transform only affects this _draw() pass.
		var s := _texture_size
		var dst := Rect2(-s * 0.5, -s * 0.5, s, s)
		if flip_h:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect(_texture, dst, false)
		if flip_h:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if pattern.is_empty():
		return
	var height := pattern.size()
	var width := 0
	for row in pattern:
		width = maxi(width, row.length())
	var offset := Vector2.ZERO
	if centered:
		offset = -Vector2(width, height) * pixel_size * 0.5
	# Mirror x so the sprite faces left when flip_h is set: x_screen = (width-1-x).
	var x_origin := 0 if not flip_h else width - 1
	var x_dir := 1 if not flip_h else -1
	for y in range(height):
		var row: String = pattern[y]
		var row_len := row.length()
		for x in range(row_len):
			var ch := row[x]
			if ch == " " or ch == ".":
				continue
			var key := String(ch)
			if not palette.has(key):
				continue
			var sx := x_origin + x_dir * x
			var rect := Rect2(offset + Vector2(sx, y) * pixel_size, Vector2(pixel_size, pixel_size))
			draw_rect(rect, palette[key])
