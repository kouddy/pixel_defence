extends Label
## A floating, fading damage number that pops upward and shrinks.
## Spawned by FX.damage_number(...).

func _ready() -> void:
	text = ""
	# Crisp pixel text, no antialiasing.
	add_theme_font_size_override("font_size", 18)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 1))
	add_theme_constant_override("outline_size", 4)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	z_index = 100
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func setup(amount: float, col: Color) -> void:
	# Round for readability; show integers — fractional damage reads as noise.
	var n: int = int(round(amount))
	text = str(n)
	add_theme_color_override("font_color", col)
	_animate()


func _animate() -> void:
	var tw := create_tween()
	# Pop scale up quickly, then ease back down while rising + fading.
	scale = Vector2(0.6, 0.6)
	tw.tween_property(self, "scale", Vector2(1.25, 1.25), 0.08).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.10)
	tw.parallel().tween_property(self, "position:y", position.y - 28, 0.5).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(queue_free)
