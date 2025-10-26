extends Node2D

@export var pet_spawn_point: Node2D

func _ready() -> void:
	for pet_data in Stats.pets:
		spawn_pet(pet_data)

func spawn_pet(pet_data: EntityData) -> void:
	var pet_name = pet_data.entity_name
	
	if PetLoader.pets.has(pet_name) and PetLoader.pets[pet_name] is PackedScene:
		var pet_instance = PetLoader.pets[pet_name].instantiate()
		pet_spawn_point.add_child(pet_instance)
		
		if pet_instance is Entity:
			pet_instance.data = pet_data
	else:
		push_warning("Pet scene not found for: " + pet_name)
