extends Control

@export var camera : Camera2D
@export var info : Control
@export var training_button: Button

var target : Node2D

func _ready() -> void:
	Global.pet_selected.connect(_on_pet_selected)
	if !training_button:
		var button_path = "path/to/Training/Button"
		training_button = get_node(button_path)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel"):
		target = null
		info.visible = false
	
	if target:
		camera.zoom = lerp(camera.zoom, Vector2(2.0, 2.0), 8.0 * delta)
		camera.global_position = lerp(camera.global_position, target.global_position + Vector2(18.0, 0), 8.0 * delta)
		if is_instance_valid(training_button):
			training_button.disabled = true
	else:
		camera.zoom = lerp(camera.zoom, Vector2.ONE, 8.0 * delta)
		camera.global_position = lerp(camera.global_position, Vector2.ZERO, 8.0 * delta)
		if is_instance_valid(training_button):
			training_button.disabled = false

func reset_camera_view() -> void:
	target = null
	info.visible = false

func _on_pet_selected(pet):
	target = pet
	info.visible = true
