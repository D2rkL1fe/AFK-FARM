extends Control

@export var farm : Farm
@export var camera : Camera2D
@export var info : Control
@export var training_button: Button

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

func _on_pet_selected(pet):
	target = pet
	info.visible = true
	
	if is_instance_valid(farm):
		farm._on_training_toggled(false)
