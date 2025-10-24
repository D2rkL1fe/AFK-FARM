extends Control

@export var camera : Camera2D
@export var info : Control

var target : Node2D

const UI_LERP_SPEED: float = 8.0 # We can use a higher speed now in _process for responsiveness

func _ready() -> void:
	# Ensure this signal is connected somewhere, likely to your pet's click logic
	Global.pet_selected.connect(_on_pet_selected)

func _process(delta: float) -> void:
	# Camera logic moved to _process (runs every frame) for smooth, non-shaking follow
	if target:
		camera.zoom = lerp(camera.zoom, Vector2(2.0, 2.0), UI_LERP_SPEED * delta)
		camera.global_position = lerp(camera.global_position, target.global_position + Vector2(18.0, 0), UI_LERP_SPEED * delta)
	else:
		camera.zoom = lerp(camera.zoom, Vector2.ONE, UI_LERP_SPEED * delta)
		camera.global_position = lerp(camera.global_position, Vector2.ZERO, UI_LERP_SPEED * delta)

# This function is called by your "Go back" button's 'pressed()' signal
# and by the _input function below.
func reset_camera_view() -> void:
	target = null
	info.visible = false

func _input(event: InputEvent) -> void:
	# Handles the ESC key to go back
	if event.is_action_pressed("cancel"):
		reset_camera_view()

func _on_pet_selected(pet):
	target = pet
	info.visible = true

func _on_feed_button_pressed() -> void:
	if target and target.data is EntityData:
		target.data.hunger = min(target.data.hunger + 25, 100)
		print("Fed " + target.data.entity_name + ". Hunger: " + str(target.data.hunger))

func _on_train_button_pressed() -> void:
	if target and target.data is EntityData:
		target.data.level += 1
		print("Trained " + target.data.entity_name + ". Level: " + str(target.data.level))

func _on_sleep_button_pressed() -> void:
	if target and target.data is EntityData:
		target.data.energy = 100
		print(target.data.entity_name + " is now fully rested.")
