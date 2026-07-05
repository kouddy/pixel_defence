extends Resource
## Data describing an enemy type.
class_name EnemyData

@export var id: StringName = &""
@export var display_name: String = "Enemy"
@export var color: Color = Color.WHITE
@export_range(8, 64) var radius: int = 16
@export var max_hp: float = 30.0
@export var speed: float = 60.0           # pixels per second along path
@export var gold_reward: int = 5
@export var armor: float = 0.0            # flat damage reduction
@export var is_flying: bool = false
@export var leaks_damage: float = 1       # how many lives a leak costs
@export var regen: float = 0.0            # HP regenerated per second (Trolls)
