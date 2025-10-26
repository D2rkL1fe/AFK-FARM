extends Node2D

@export var pet_spawn_point: Node2D

func _ready() -> void:
	# Assuming this is where you load and spawn the pets for the expedition
	# You'll need to load the actual pet data here if not done already
	# For demonstration, I'm using a placeholder list of pet data
	var pet_data_list = get_tree().get_nodes_in_group("farm_pets")
	for pet_data in pet_data_list:
		if pet_data is EntityData: # Assuming you have a way to access the pet's data resource
			spawn_pet(pet_data)

func spawn_pet(pet_data: EntityData) -> void:
	var pet_name = pet_data.entity_name
	
	if PetLoader.pets.has(pet_name) and PetLoader.pets[pet_name] is PackedScene:
		var pet_instance = PetLoader.pets[pet_name].instantiate()
		pet_instance.global_position = pet_spawn_point.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		pet_spawn_point.add_child(pet_instance)
		
		if pet_instance.is_in_group("pet_entity"):
			pet_instance.data = pet_data
			# Crucial: Set the pet to wandering so it starts moving
			pet_instance.current_state = pet_instance.State.WANDERING
			pet_instance.move()
		else:
			push_warning("Pet scene not found for pet: " + pet_name)
