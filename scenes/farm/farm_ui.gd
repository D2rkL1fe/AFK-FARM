extends Control
class_name FarmUISettings

signal reset_camera_view_signal
signal focus_pet_signal(target: Entity)

@onready var pet_info_panel: PanelContainer = $PetInfoPanel
@onready var pet_name_label: Label = $PetInfoPanel/VBoxContainer.find_child("NameLabel", false)
@onready var hunger_progress: ProgressBar = $PetInfoPanel/VBoxContainer.find_child("HungerBar", false)
@onready var pet_love_label: Label = $PetInfoPanel/VBoxContainer.find_child("LoveLabel", false)

var focused_pet: Entity = null

func _ready():
	pet_info_panel.hide()
	
	var manager = get_tree().get_first_node_in_group("ExpeditionManager")
	if manager:
		manager.pet_interacted.connect(open_pet_interaction_menu)

func update_ui_display() -> void:
	if focused_pet:
		if pet_name_label:
			pet_name_label.text = focused_pet.data.entity_name
		if hunger_progress:
			hunger_progress.value = focused_pet.data.hunger
		if pet_love_label:
			pet_love_label.text = "Love: %d" % focused_pet.data.love

func open_pet_interaction_menu(pet: Entity) -> void:
	focused_pet = pet
	focus_pet_signal.emit(pet)
	update_ui_display()
	pet_info_panel.show()

func _on_feed_button_pressed() -> void:
	if focused_pet:
		focused_pet.data.hunger = min(100, focused_pet.data.hunger + 15)
		focused_pet.data.love = min(999, focused_pet.data.love + 1)
		update_ui_display()
		print(focused_pet.data.entity_name + " was fed!")

func _on_close_button_pressed() -> void:
	focused_pet = null
	pet_info_panel.hide()
	reset_camera_view_signal.emit()
