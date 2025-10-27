extends Node2D

@export var pet_spawn_point: Node2D

@export var food : Array[PackedScene]

func _ready() -> void:
	spawn_pet()

func spawn_pet() -> void:
	for pet_data in Stats.pets:
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

func spawn_food():
	var random = randi_range(0, food.size() - 1)
	
	var instance = food[random].instantiate()
	
	var dist : int = 50
	instance.global_position = Vector2(randf_range(-dist, dist), randf_range(-dist, dist))
	
	add_child(instance)


func _on_food_timer_timeout() -> void:
	spawn_food()
