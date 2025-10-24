extends Control

@export var camera : Camera2D
@export var info : Control

var target : Node2D

func _ready() -> void:
	Global.pet_selected.connect(_on_pet_selected)

func _physics_process(delta: float) -> void:
	# input
	if Input.is_action_just_pressed("cancel"):
		target = null
		info.visible = false
	
	# animations
	if target:
		camera.zoom = lerp(camera.zoom, Vector2(2.0, 2.0), 8.0 * delta)
		camera.global_position = lerp(camera.global_position, target.global_position + Vector2(18.0, 0), 8.0 * delta)
	else:
		camera.zoom = lerp(camera.zoom, Vector2.ONE, 8.0 * delta)
		camera.global_position = lerp(camera.global_position, Vector2.ZERO, 8.0 * delta)

func _on_pet_selected(pet):
	target = pet
	info.visible = true
