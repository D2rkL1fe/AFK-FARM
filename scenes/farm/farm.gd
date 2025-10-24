extends Node
class_name Farm

signal pet_interacted(pet_instance: Node2D)
signal void_clicked

@export var spawn : Node2D

func _ready() -> void:
	spawn_pets()
	set_process_input(true)

func spawn_pets():
	for pet_data in Stats.pets:
		var scene_to_load = PetLoader.pets[pet_data.base_name]
		
		if scene_to_load is PackedScene:
			var instance = scene_to_load.instantiate()
			instance.data = pet_data
			
			instance.global_position = spawn.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			
			instance.interacted.connect(_on_pet_interacted)
			
			spawn.add_child(instance)
		else:
			print("Error: Could not find PackedScene for base name: %s" % pet_data.base_name)

func _on_pet_interacted(pet: Node2D) -> void:
	pet_interacted.emit(pet)
	Global.pet_selected.emit(pet)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_viewport().is_input_handled():
			void_clicked.emit()
			get_viewport().set_input_as_handled()
