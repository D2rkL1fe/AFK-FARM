extends Control

@export var camera : Camera2D
@export var info : Control
@export var training_button: Button
@export var level_label: Label
@export var experience_label: Label
@export var hunger_label: Label
@export var energy_label: Label

var target : Node2D

func _ready() -> void:
	Global.pet_selected.connect(_on_pet_selected)

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
		level_label.text = "Lvl: " + str(pet.level)
	if is_instance_valid(experience_label):
		experience_label.text = "EXP: " + str(int(pet.current_exp)) + " / " + str(pet.exp_to_next_level)
	if is_instance_valid(hunger_label):
		hunger_label.text = "HUNGER: " + str(int(pet.current_hunger)) + "/100"
	if is_instance_valid(energy_label):
		energy_label.text = "ENERGY: " + str(int(pet.current_energy)) + "/" + str(int(pet.get_max_energy()))


func _on_pet_selected(pet):
	target = pet
	info.visible = true
	refresh_pet_info(pet)
