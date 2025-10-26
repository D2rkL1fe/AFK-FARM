extends Control
class_name FarmUI

const DISPLAY_XP_DIVISOR = 1
const CARROT_HUNGER_RESTORE: float = 10.0
const CARROT_ENERGY_RESTORE: float = 5.0
const POTATO_HUNGER_RESTORE: float = 10.0
const POTATO_ENERGY_RESTORE: float = 5.0
const HUNGER_THRESHOLD_TO_CONSUME: float = 90.0

var level_label: Label
var experience_label: Label
var wandering_label: Label
var hunger_label: Label
var energy_label: Label
var stats_panel: Control
var carrot_label: Label
var potato_label: Label

var selected_pet: Entity = null

func _ready():
	# Get UI references via path relative to this Control node
	stats_panel = get_node("PetStatsPanel")
	level_label = stats_panel.get_node("VBoxContainer/Info/MarginContainer/VBoxContainer/Level")
	experience_label = stats_panel.get_node("VBoxContainer/Info/MarginContainer/VBoxContainer/Experience")
	wandering_label = stats_panel.get_node("VBoxContainer/Info/MarginContainer/VBoxContainer/Wandering")
	hunger_label = stats_panel.get_node("VBoxContainer/Info/MarginContainer/VBoxContainer/Hunger")
	energy_label = stats_panel.get_node("VBoxContainer/Info/MarginContainer/VBoxContainer/Energy")
	
	carrot_label = stats_panel.get_node("FoodPanel/HBoxContainer/Carrot/CarrotLabel")
	potato_label = stats_panel.get_node("FoodPanel/HBoxContainer/Potato/PotatoLabel")
	
	if is_instance_valid(Stats):
		Stats.food_changed.connect(_update_inventory_display)
		Stats.food_changed.connect(_on_food_changed)

func _process(delta):
	if is_instance_valid(selected_pet) and stats_panel.visible:
		_update_stats_display(selected_pet)

func show_stats_panel(pet: Entity):
	selected_pet = pet
	stats_panel.visible = true
	_update_stats_display(pet)
	_update_inventory_display()

func hide_stats_panel():
	selected_pet = null
	stats_panel.visible = false

func _update_stats_display(pet: Entity):
	if !is_instance_valid(level_label): return
	
	var current_exp_display = int(pet.data.current_exp / DISPLAY_XP_DIVISOR)
	var exp_to_next_level_display = int(pet.data.exp_to_next_level / DISPLAY_XP_DIVISOR)
	level_label.text = "Lvl: " + str(pet.data.level)
	experience_label.text = "EXP: " + str(current_exp_display) + " / " + str(exp_to_next_level_display)
	
	var current_wander_exp_display = int(pet.data.current_wandering_exp / DISPLAY_XP_DIVISOR)
	var wander_exp_to_next_level_display = int(pet.data.wandering_exp_to_next_level / DISPLAY_XP_DIVISOR)
	wandering_label.text = "WANDER: Lvl " + str(pet.data.wandering_level) + " (" + str(current_wander_exp_display) + " / " + str(wander_exp_to_next_level_display) + ")"
	
	hunger_label.text = "HUNGER: " + str(snapped(pet.data.hunger, 1)) + "/100"
	energy_label.text = "ENERGY: " + str(snapped(pet.data.energy, 1)) + "/" + str(snapped(pet.get_max_energy(), 1))

func _update_inventory_display():
	if !is_instance_valid(carrot_label): return
	
	carrot_label.text = "Carrot: " + str(Stats.carrot_amount)
	potato_label.text = "Potato: " + str(Stats.potato_amount)

func _on_food_changed():
	if !is_instance_valid(selected_pet):
		return
	
	if selected_pet.data.hunger >= HUNGER_THRESHOLD_TO_CONSUME:
		return
		
	var consumed: bool = false
	
	if Stats.carrot_amount > 0:
		Stats.carrot_amount -= 1
		selected_pet.eat_food(CARROT_HUNGER_RESTORE, CARROT_ENERGY_RESTORE)
		consumed = true
	elif Stats.potato_amount > 0:
		Stats.potato_amount -= 1
		selected_pet.eat_food(POTATO_HUNGER_RESTORE, POTATO_ENERGY_RESTORE)
		consumed = true
		
	if consumed:
		Stats.food_changed.emit()
