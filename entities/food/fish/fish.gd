extends Node2D
class_name Fish

@export var hunger_restore: float = 20.0
@export var energy_restore: float = 10.0

func _on_interacted(pet_instance):
	if pet_instance is Entity:
		pet_instance.eat_fish(hunger_restore, energy_restore)
		queue_free()
