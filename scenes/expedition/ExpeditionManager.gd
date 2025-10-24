extends Node2D
class_name ExpeditionManager

# Load all pets (more can be added later)
var pets: Dictionary = {
	"Cow": preload("uid://corsjmf04ogm8"), # Replace with your actual Cow scene UID
	# "Slime": preload("uid://d2031h3r0fx"), # Uncomment when you add Slime
}

# Holds currently spawned pet instances
var active_pets: Array = []


func _ready() -> void:
	# Example: spawn several cows for testing
	for i in range(5):
		var pos := Vector2(randf_range(-100, 100), randf_range(-100, 100))
		spawn_pet("Cow", pos)


func spawn_pet(pet_name: String, spawn_pos: Vector2) -> void:
	if pets.has(pet_name):
		var pet_scene: PackedScene = pets[pet_name]
		var pet_instance: Node2D = pet_scene.instantiate()
		pet_instance.global_position = spawn_pos
		add_child(pet_instance)
		active_pets.append(pet_instance)
	else:
		push_warning("Pet not found in pets list: " + pet_name)
