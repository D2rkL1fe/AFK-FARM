extends Resource
class_name EntityData

@export var entity_name: String = "Pet"
@export var description: String = "A friendly little creature."

@export var love: int = 0
@export var energy: float = 100.0
@export var level: int = 1
@export var hunger: float = 100.0

@export var current_exp: float = 0.0
@export var exp_to_next_level: float = 30.0
@export var wandering_level: int = 1
@export var current_wandering_exp: float = 0.0
@export var wandering_exp_to_next_level: float = 100.0

@export var move_speed_multiplier: float = 0.0
@export var energy_cost_multiplier: float = 0.0
@export var exp_gain_multiplier: float = 0.0

@export var inventory: Dictionary = {} # Inside your EntityData.gd (Resource) script:

# --- Wandering/Movement State ---
@export var wander_radius_base: float = 50.0
@export var wander_search_radius: float = 50.0
@export var last_wandered_pos: Vector2 = Vector2.ZERO
@export var last_wandered_time: float = 0.0
