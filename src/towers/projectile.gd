extends Area2D
## Projectile: travels toward a target; on hit applies damage (and splash if set).

@onready var sprite: ColorRect = $Sprite

var target: Node2D = null
var speed: float = 350.0
var damage: float = 10.0
var splash: bool = false
var splash_radius: float = 0.0
var slows: bool = false
var slow_factor: float = 0.5
var slow_duration: float = 1.0
var _color: Color = Color.WHITE


func _ready() -> void:
	sprite.color = _color
	sprite.size = Vector2(8, 8)
	sprite.position = -sprite.size * 0.5
	monitoring = true


func configure(t: Node2D, dmg: float, spd: float, c: Color,
		is_splash: bool, s_radius: float, slow: bool,
		s_factor: float, s_dur: float) -> void:
	target = t
	damage = dmg
	speed = spd
	_color = c
	splash = is_splash
	splash_radius = s_radius
	slows = slow
	slow_factor = s_factor
	slow_duration = s_dur
	if sprite:
		sprite.color = c


func _process(dt: float) -> void:
	if not is_instance_valid(target):
		# Target gone — expire projectile.
		queue_free()
		return
	var dir: Vector2 = (target.global_position - global_position)
	var dist := dir.length()
	if dist < 6.0:
		_impact()
		return
	dir = dir.normalized()
	global_position += dir * speed * dt
	rotation = dir.angle()


func _impact() -> void:
	if splash:
		for e in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(e) or not e.is_alive():
				continue
			if global_position.distance_to(e.global_position) <= splash_radius:
				_hit(e)
	else:
		if is_instance_valid(target):
			_hit(target)
	_spawn_impact()
	queue_free()


func _hit(e: Node2D) -> void:
	e.take_damage(damage)
	if slows and e.has_method("apply_slow"):
		e.apply_slow(slow_factor, slow_duration)


func _spawn_impact() -> void:
	# Splash impacts get a bigger ring + screen shake; single hits get a small flash.
	FX.flash_at(global_position, _color, 14.0)
	if splash:
		FX.ring(global_position, _color, splash_radius)
		FX.burst(global_position, _color, 10, 70.0)
		FX.screen_shake(3.0, 0.12)
	else:
		FX.burst(global_position, _color, 4, 40.0)
