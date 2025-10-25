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

func reset_camera_view() -> void:
	target = null
	info.visible = false

func _on_pet_selected(pet):
	target = pet
	info.visible = true
