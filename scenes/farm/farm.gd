extends Node2D
class_name Farm

@export var spawn : Node2D

func _ready() -> void:
	spawn_pets()

func spawn_pets():
	for pet in Stats.pets:
		var instance = PetLoader.pets[pet.entity_name].instantiate()
		
		instance.global_position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		
		spawn.add_child(instance)
