extends Resource
## Data describing a buildable tower/defender unit.
class_name UnitData

enum AttackType { MELEE, PROJECTILE, SPLASH }

@export var id: StringName = &""
@export var display_name: String = "Unit"
@export var description: String = ""
@export var color: Color = Color.WHITE
@export_range(8, 64) var radius: int = 20
@export var attack_type: AttackType = AttackType.PROJECTILE

@export var cost: int = 50
@export var damage: float = 10.0
@export var range_px: float = 120.0
@export var fire_rate: float = 1.0      # shots per second
@export var splash_radius: float = 0.0  # 0 = single target
@export var projectile_speed: float = 350.0
@export var can_hit_air: bool = true
@export var slows_on_hit: bool = false
@export var slow_factor: float = 0.5
@export var slow_duration: float = 1.0

# Mobile-tower fields. Zero means static (every tower except the prince), so
# these are inert by default and the existing towers are unchanged. The prince
# sets move_speed > 0 to chase enemies, melee_range_px as its sword reach, and
# melee_damage as the sword's hit (separate from the ranged `damage`/bow).
@export var move_speed: float = 0.0
@export var melee_range_px: float = 0.0
@export var melee_damage: float = 0.0
