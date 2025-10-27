extends Node

var pets: Array[EntityData] = []

var last_time_played : int

var carrot_amount : int = 0
var potato_amount : int = 0

signal food_changed

func _ready() -> void:
	var now = Time.get_unix_time_from_system()
	
	SaveLoad.SaveFileData.total_time_afk = now - SaveLoad.SaveFileData.last_time_played
	SaveLoad.SaveFileData.last_time_played = now
	
	SaveLoad._save()
	
	var pet_data = PetLoader.pets["Cow"].instantiate().data.duplicate()
	
	for i in range(10):
		pets.append(pet_data)
