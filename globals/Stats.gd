extends Node

var pets: Array[EntityData] = []

func _ready() -> void:
	var data = PetLoader.pets["Cow"].instantiate().data.duplicate()
	
	for i in range(10):
		pets.append(data)
	
