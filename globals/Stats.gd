extends Node

var pets: Array[EntityData] = []

var last_time_played : int

func _ready() -> void:
	# session stuff
	var now = Time.get_unix_time_from_system()
	print(now - SaveLoad.SaveFileData.last_time_played)
	
	SaveLoad.SaveFileData.last_time_played = now
	SaveLoad._save()
	
	# load pet/item data
	var pet_data = PetLoader.pets["Cow"].instantiate().data.duplicate()
	
	for i in range(10):
		pets.append(pet_data)
	
