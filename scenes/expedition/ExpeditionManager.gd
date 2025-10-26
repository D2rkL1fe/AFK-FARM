extends Node2D
class_name ExpeditionManager

signal pet_interacted(pet_instance: Entity)

var pets: Dictionary = {
	"Cow": preload("uid://corsjmf04ogm8"),
}

var active_pets: Array = []

func _ready() -> void:
	for pet_data in Stats.pets:
		spawn_pet(pet_data.entity_name, Vector2(randf_range(-10, 10), randf_range(-10, 10)))

func spawn_pet(pet_name: String, spawn_pos: Vector2) -> void:
	if pets.has(pet_name):
		var pet_instance: Entity = pets[pet_name].instantiate()
		pet_instance.global_position = spawn_pos
		add_child(pet_instance)
		active_pets.append(pet_instance)
		pet_instance.interacted.connect(_on_pet_interacted)
	else:
		push_warning("Pet not found in pets list: " + pet_name)

func _on_pet_interacted(pet_instance: Entity) -> void:
	print("Pet clicked: " + pet_instance.data.entity_name)
	pet_interacted.emit(pet_instance)
