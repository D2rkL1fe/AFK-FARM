extends Node

# technically its entities but ok
var pets : Array[EntityData]

func _ready() -> void:
	var data = PetLoader.pets["Cow"].instantiate().data
	
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
	pets.append(data)
