class_name Farm
extends Node2D

@export var spawn : Node2D
@export var training_button: Button

@export var total_rewards : Control
@export var afk_rewards : Control

var is_training: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var total_mouse_distance: float = 0.0
var training_start_time: float = 0.0

const XP_DIVISOR = 10.0
const WANDERING_XP_BOOST = 5.0
const carrot_HUNGER_VALUE = 20.0
const carrot_ENERGY_VALUE = 10.0
const POTATO_HUNGER_VALUE = 15.0
const POTATO_ENERGY_VALUE = 5.0

func _ready() -> void:
	# handle data
	if SaveLoad.SaveFileData.playing_first_time:
		SaveLoad.SaveFileData.playing_first_time = false
		SaveLoad._save()
	elif !Stats.claimed_afk_reward:
		var total_food = min(SaveLoad.SaveFileData.total_time_afk, 1000)
		
		var n_carrots = int(total_food / 2) + randi_range(0, int(total_food / 10) + 15)
		var n_potatoes = int(total_food / 2) + randi_range(0, int(total_food / 10) + 15)
		
		Stats.total_carrot_amount += n_carrots
		Stats.total_potato_amount += n_potatoes
		
		Stats.claimed_afk_reward = true
		
		Stats.food_changed.emit()
		
		afk_rewards.activate(n_carrots, n_potatoes)
		
		SaveLoad.SaveFileData.total_carrot_amount = Stats.total_carrot_amount
		SaveLoad.SaveFileData.total_potato_amount = Stats.total_potato_amount
		SaveLoad._save()
	
	# handle rewards
	if Stats.carrot_amount > 0 or Stats.potato_amount > 0:
		total_rewards.activate()
		
		Stats.carrot_amount = 0
		Stats.potato_amount = 0
		
		SaveLoad.SaveFileData.total_carrot_amount = Stats.total_carrot_amount
		SaveLoad.SaveFileData.total_potato_amount = Stats.total_potato_amount
		SaveLoad._save()
	
	# mazno
	add_to_group("farm_root")
	spawn_pets()

func spawn_pets():
	for pet_data in Stats.pets:
		var pet_name = pet_data.entity_name
		if PetLoader.pets.has(pet_name) and PetLoader.pets[pet_name] is PackedScene:
			var instance = PetLoader.pets[pet_name].instantiate()
			# Spawn pets within the visible farm area
			instance.global_position = Vector2(randf_range(-75, 75), randf_range(-75, 75))
			spawn.add_child(instance)

func _physics_process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if is_training and event is InputEventMouseMotion:
		var current_mouse_pos = get_global_mouse_position()
		var distance = last_mouse_pos.distance_to(current_mouse_pos)
		total_mouse_distance += distance
		last_mouse_pos = current_mouse_pos
		
	if is_training and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		target_pets(get_global_mouse_position())
		last_mouse_pos = get_global_mouse_position()

func _on_food_clicked(food_instance) -> void:
	var pets = spawn.get_children().filter(func(child): return child is Entity)
	
	var total_pets = pets.size()
	if total_pets == 0:
		return

	var hunger_value: float = 0.0
	var energy_value: float = 0.0
	
	if food_instance.get_script().get_instance_base_type() == "carrot":
		hunger_value = carrot_HUNGER_VALUE
		energy_value = carrot_ENERGY_VALUE
	elif food_instance.get_script().get_instance_base_type() == "Potato":
		hunger_value = POTATO_HUNGER_VALUE
		energy_value = POTATO_ENERGY_VALUE
	else:
		return

	var hunger_share = hunger_value / total_pets
	var energy_share = energy_value / total_pets
	
	for pet in pets:
		pet.eat_food(hunger_share, energy_share)
		if is_instance_valid(pet.data):
			# These lines are redundant but kept for clarity on what is being updated
			pet.data.hunger = pet.data.hunger
			pet.data.energy = pet.data.energy

func _on_training_toggled(_toggled_on: bool) -> void:
	is_training = _toggled_on
	training_button.button_pressed = _toggled_on
	
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
			child.start_following_mouse(pos)

func stop_training() -> void:
	var training_time_seconds = Time.get_ticks_usec() / 1000000.0 - training_start_time
	training_time_seconds = max(1.0, training_time_seconds)
	
	var _training_speed = total_mouse_distance / training_time_seconds
	
	var base_gain = int(total_mouse_distance / XP_DIVISOR)
	
	total_mouse_distance = 0.0
	
	var control_node = get_node("CanvasLayer/CameraControl")
	var focused_pet: Entity = null
	
	for child in spawn.get_children():
		if child is Entity:
			var xp_gained = max(1, base_gain)
			var final_xp_gain = max(1, int(xp_gained * child.data.exp_gain_multiplier)) 
			
			child.data.current_exp += final_xp_gain
			child.data.current_wandering_exp += final_xp_gain * WANDERING_XP_BOOST
			
			child.level_up()
			child.wandering_level_up()
				
			child.stop_following()
			
			if control_node and control_node.target == child:
				focused_pet = child

	if focused_pet and control_node:
		control_node.refresh_pet_info(focused_pet)


func _on_settings_pressed() -> void:
	Settings.toggle()
