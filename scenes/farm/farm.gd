extends Node2D

@export var spawn : Node2D
@export var training_button: Button

var is_training: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var total_mouse_distance: float = 0.0
var training_start_time: float = 0.0

const XP_DIVISOR = 20.0
const FISH_HUNGER_VALUE = 40.0
const FISH_ENERGY_VALUE = 20.0

func _ready() -> void:
	add_to_group("farm_root")
	spawn_pets()

func spawn_pets():
	for pet in Stats.pets:
		var instance = PetLoader.pets[pet.entity_name].instantiate()
		instance.global_position = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		spawn.add_child(instance)

func _physics_process(_delta: float) -> void:
	if is_training:
		for child in spawn.get_children():
			if child is Entity:
				if child.current_state == Entity.State.FOLLOWING_MOUSE:
					if child.current_energy <= 5:
						child.stop_following()
					
func _input(event: InputEvent) -> void:
	if is_training and event is InputEventMouseMotion:
		var current_mouse_pos = get_global_mouse_position()
		var distance = last_mouse_pos.distance_to(current_mouse_pos)
		total_mouse_distance += distance
		
	if is_training and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target_pets(get_global_mouse_position())

func _on_fish_clicked(_fish_instance) -> void:
	var pets = spawn.get_children().filter(func(child): return child is Entity)
	
	var total_pets = pets.size()
	if total_pets == 0:
		return

	var hunger_share = FISH_HUNGER_VALUE / total_pets
	var energy_share = FISH_ENERGY_VALUE / total_pets
	
	for pet in pets:
		pet.eat_fish(hunger_share, energy_share)
		
	print("Pets ate fish! Hunger gained: ", hunger_share, " Energy gained: ", energy_share)

func _on_training_toggled(_toggled_on: bool) -> void:
	is_training = _toggled_on
	if is_training:
		training_start_time = Time.get_ticks_usec() / 1000000.0
		last_mouse_pos = get_global_mouse_position()
		total_mouse_distance = 0.0
		var control_node = get_node("CanvasLayer/CameraControl") 
		if control_node and control_node.target:
			control_node.reset_camera_view()
	else:
		stop_training()

func target_pets(pos: Vector2) -> void:
	for child in spawn.get_children():
		if child is Entity:
			if child.current_energy > 5:
				child.start_following_mouse(pos)

func stop_training() -> void:
	var training_time_seconds = Time.get_ticks_usec() / 1000000.0 - training_start_time
	training_time_seconds = max(1.0, training_time_seconds) 
	
	var _training_speed = total_mouse_distance / training_time_seconds
	
	var base_gain = int(total_mouse_distance / XP_DIVISOR)
	
	print("Training complete! Distance: ", total_mouse_distance, " Gain: ", base_gain)
	
	total_mouse_distance = 0.0
	
	var control_node = get_node("CanvasLayer/CameraControl")
	var focused_pet: Entity = null
	
	for child in spawn.get_children():
		if child is Entity:
			var xp_gained = max(1, base_gain)
			var final_xp_gain = max(1, int(xp_gained * child.exp_gain_multiplier)) 
			child.current_exp += final_xp_gain
			
			if child.current_exp >= child.exp_to_next_level:
				child.level_up()
				
			child.stop_following()
			
			if control_node and control_node.target == child:
				focused_pet = child

	if focused_pet and control_node:
		control_node.refresh_pet_info(focused_pet)
