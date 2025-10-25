extends Node2D
class_name Farm

@export var spawn : Node2D
@export var training_button: Button

var is_training: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var total_mouse_distance: float = 0.0

func _ready() -> void:
	spawn_pets()

func spawn_pets():
	for pet in Stats.pets:
		var instance = PetLoader.pets[pet.entity_name].instantiate()
		
		instance.global_position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		
		spawn.add_child(instance)

func _input(event: InputEvent) -> void:
	if is_training and event is InputEventMouseMotion:
		var current_mouse_pos = get_global_mouse_position()
		var distance = last_mouse_pos.distance_to(current_mouse_pos)
		total_mouse_distance += distance
		last_mouse_pos = current_mouse_pos
	
	if is_training and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target_pets(get_global_mouse_position())

func _on_training_toggled(_toggled_on: bool) -> void:
	is_training = _toggled_on
	if is_training:
		last_mouse_pos = get_global_mouse_position()
		total_mouse_distance = 0.0
		var control_node = get_node("CameraControl")
		if control_node and control_node.target:
			control_node.reset_camera_view()
	else:
		stop_training()

func target_pets(pos: Vector2) -> void:
	for child in spawn.get_children():
		if child is Entity:
			child.start_following_mouse(pos)

func stop_training() -> void:
	var training_time_seconds = 1
	var _training_speed = total_mouse_distance / max(1.0, training_time_seconds)
	
	var training_gain = int(total_mouse_distance / 100.0)
	print("Training complete! Distance: ", total_mouse_distance, " Gain: ", training_gain)
	
	total_mouse_distance = 0.0
	for child in spawn.get_children():
		if child is Entity:
			child.stop_following()
