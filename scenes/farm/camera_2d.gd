extends Control

@export var level_label: Label
@export var experience_label: Label
@export var hunger_label: Label
@export var energy_label: Label
@export var wandering_label: Label
@export var nav_panel_ref: Control 

const DISPLAY_XP_DIVISOR: float = 1.0
const EXP_DISPLAY_SCALE: float = 100.0

var target: Entity = null

func _ready() -> void:
	self.hide()

func show_stats_panel(pet: Entity):
	if is_instance_valid(nav_panel_ref):
		nav_panel_ref.hide()
	
	self.show()
	target = pet
	refresh_pet_info(pet)

func hide_stats_panel():
	if is_instance_valid(nav_panel_ref):
		nav_panel_ref.show()
		
	self.hide()
	target = null

func reset_camera_view():
	pass

func refresh_pet_info(pet: Entity) -> void:
	if is_instance_valid(pet):
		if is_instance_valid(level_label):
			level_label.text = "Lvl: " + str(pet.data.level)
			
		if is_instance_valid(experience_label):
			var current_exp_display = int(pet.data.current_exp / EXP_DISPLAY_SCALE)
			var exp_to_next_level_display = int(pet.data.exp_to_next_level / EXP_DISPLAY_SCALE)
			experience_label.text = "EXP: " + str(current_exp_display) + " / " + str(exp_to_next_level_display)
			
		if is_instance_valid(hunger_label):
			hunger_label.text = "HUNGER: " + str(int(pet.data.hunger)) + " / 100"
			
		if is_instance_valid(energy_label):
			energy_label.text = "ENERGY: " + str(int(pet.data.energy)) + " / " + str(int(pet.get_max_energy()))
			
		if is_instance_valid(wandering_label):
			var current_wander_exp_display = int(pet.data.current_wandering_exp / EXP_DISPLAY_SCALE)
			var wander_exp_to_next_level_display = int(pet.data.wandering_exp_to_next_level / EXP_DISPLAY_SCALE)
			
			wandering_label.text = "WANDER: Lvl " + str(pet.data.wandering_level) + " (" + str(current_wander_exp_display) + " / " + str(wander_exp_to_next_level_display) + ")"

func _on_pet_selected(pet: Entity):
	show_stats_panel(pet)
