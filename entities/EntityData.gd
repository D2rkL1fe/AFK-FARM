extends Resource
class_name EntityData

@export var base_name: String = ""
@export var entity_name: String = "Untitled Pet"

@export var love: int = 0
@export var energy: int = 100
@export var level: int = 1
@export var hunger: int = 100

func _init(p_name: String = "Untitled Pet", p_base: String = "") -> void:
	entity_name = p_name
	base_name = p_base
