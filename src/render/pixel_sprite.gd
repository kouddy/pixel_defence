extends Node2D
## PixelSprite: renders a small pixel-art sprite from an ASCII grid.
## Each character in `pattern` maps to a Color via `palette`.
## ' ' and '.' are transparent. Drawn via _draw() so it stays crisp at any zoom.
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


func _ready() -> void:
	queue_redraw()


func configure(pat: PackedStringArray, pal: Dictionary, psize: float) -> void:
	pattern = pat
	palette = pal
	pixel_size = psize
	queue_redraw()


## Toggle horizontal mirroring and redraw. Use this rather than setting flip_h
## directly so the change is reflected immediately.
func set_flip_h(v: bool) -> void:
	if flip_h == v:
		return
	flip_h = v
	queue_redraw()


func _draw() -> void:
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
