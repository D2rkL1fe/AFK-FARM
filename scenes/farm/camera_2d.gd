extends Control

@export var camera : Camera2D
@export var info : Control
@export var training_button: Button
@export var level_label: Label
@export var experience_label: Label
@export var hunger_label: Label
@export var energy_label: Label
@export var wandering_label: Label
@export var carrot_label: Label
@export var potato_label: Label

const CARROT_HUNGER_RESTORE: float = 10.0
const CARROT_ENERGY_RESTORE: float = 5.0
const POTATO_HUNGER_RESTORE: float = 10.0
const POTATO_ENERGY_RESTORE: float = 5.0
const HUNGER_THRESHOLD_TO_CONSUME: float = 90.0

var target : Node2D

func _ready() -> void:
	Global.pet_selected.connect(_on_pet_selected)
	if is_instance_valid(Stats):
		Stats.food_changed.connect(_update_inventory_display)
		Stats.food_changed.connect(_on_food_changed)
		_update_inventory_display()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		target = null
		info.visible = false
	
	if target:
		camera.zoom = lerp(camera.zoom, Vector2(2.0, 2.0), 8.0 * _delta)
		camera.global_position = lerp(camera.global_position, target.global_position + Vector2(18.0, 0), 8.0 * _delta)
		
		if target is Entity:
			refresh_pet_info(target)
			
		if is_instance_valid(training_button):
			training_button.visible = false
			info.visible = true
	else:
		camera.zoom = lerp(camera.zoom, Vector2.ONE, 8.0 * _delta)
		camera.global_position = lerp(camera.global_position, Vector2.ZERO, 8.0 * _delta)
		if is_instance_valid(training_button):
			training_button.visible = true
			info.visible = false
			
func reset_camera_view() -> void:
	target = null
	info.visible = false
	
func refresh_pet_info(pet: Entity) -> void:
	if is_instance_valid(level_label):
		level_label.text = "Lvl: " + str(pet.data.level)
	if is_instance_valid(experience_label):
		experience_label.text = "EXP: " + str(int(pet.data.current_exp)) + " / " + str(pet.data.exp_to_next_level)
	if is_instance_valid(hunger_label):
		hunger_label.text = "HUNGER: " + str(int(pet.data.hunger)) + "/100"
	if is_instance_valid(energy_label):
		energy_label.text = "ENERGY: " + str(int(pet.data.energy)) + "/" + str(int(pet.get_max_energy()))
	if is_instance_valid(wandering_label):
		wandering_label.text = "WANDER: Lvl " + str(pet.data.wandering_level) + " (" + str(int(pet.data.current_wandering_exp)) + " / " + str(pet.data.wandering_exp_to_next_level) + ")"

func _update_inventory_display():
	if is_instance_valid(carrot_label):
		carrot_label.text = "Carrot: " + str(Stats.carrot_amount)
	if is_instance_valid(potato_label):
		potato_label.text = "Potato: " + str(Stats.potato_amount)

func _on_food_changed():
	if !is_instance_valid(target) or !(target is Entity):
		return
	
	var pet: Entity = target
	
	if pet.data.hunger >= HUNGER_THRESHOLD_TO_CONSUME:
		return
		
	var consumed: bool = false
	
	if Stats.carrot_amount > 0:
		Stats.carrot_amount -= 1
		pet.eat_food(CARROT_HUNGER_RESTORE, CARROT_ENERGY_RESTORE)
		consumed = true
	elif Stats.potato_amount > 0:
		Stats.potato_amount -= 1
		pet.eat_food(POTATO_HUNGER_RESTORE, POTATO_ENERGY_RESTORE)
		consumed = true
		
	if consumed:
		Stats.food_changed.emit()
		refresh_pet_info(pet)

func _on_pet_selected(pet):
	target = pet
	info.visible = true
	refresh_pet_info(pet)
