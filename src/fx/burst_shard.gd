extends ColorRect
## A single colored pixel shard that flies to a target offset, shrinks and fades.
## Used in death/hit bursts — spawned in groups by FX.burst(...).

func _ready() -> void:
	size = Vector2(6, 6)
	position = -size * 0.5
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func launch(col: Color, offset: Vector2) -> void:
	color = col
	var tw := create_tween()
	tw.tween_property(self, "position", position + offset, 0.32).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(0.2, 0.2), 0.32).set_trans(Tween.TRANS_QUAD)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.32)
	tw.tween_callback(queue_free)
