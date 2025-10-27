extends Node

var pets: Array[EntityData] = []

var last_time_played : int

var claimed_afk_reward : bool = false

# food
var total_carrot_amount : int = 0
var total_potato_amount : int = 0

var carrot_amount : int = 0
var potato_amount : int = 0

signal food_changed

func _ready() -> void:
	# handle food
	total_carrot_amount = SaveLoad.SaveFileData.total_carrot_amount
	total_potato_amount = SaveLoad.SaveFileData.total_potato_amount
	
	# handle time
	var now = Time.get_unix_time_from_system()
	
	SaveLoad.SaveFileData.total_time_afk = now - SaveLoad.SaveFileData.last_time_played
	SaveLoad.SaveFileData.last_time_played = now
	
	SaveLoad._save()
	
	# pet data
	for i in range(6):
		var cow_data = PetLoader.pets["Cow"].instantiate().data.duplicate()
		pets.append(cow_data)
	for i in range(4):
		var chicken_data = PetLoader.pets["Chicken"].instantiate().data.duplicate()
		pets.append(chicken_data)
