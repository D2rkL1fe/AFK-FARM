extends Node

var pets: Array[EntityData] = []

func _ready() -> void:
	var base_scene: PackedScene = PetLoader.pets["Cow"]
	
	for i in range(17):
		var pet_instance = base_scene.instantiate() 
		var data_copy: EntityData = pet_instance.data.duplicate()
		
		data_copy.entity_name = "Cow_%d" % i
		data_copy.base_name = "Cow"
		data_copy.love = randi() % 10
		data_copy.energy = 100
		data_copy.level = 1
		
		pets.append(data_copy)
		
		pet_instance.queue_free()
