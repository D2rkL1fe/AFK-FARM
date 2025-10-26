extends Control

@export var camera: Camera2D 
@export var info: Control     
@export var farm: Node2D     
@export var training_button: Button 

@export var stats_container: VBoxContainer # This VBoxContainer holds all the dynamically generated stats

const DISPLAY_XP_DIVISOR: float = 1.0
const EXP_DISPLAY_SCALE: float = 100.0

var target: Entity = null

var pets_panel: Control = null 
var carrot_inventory_label: Label = null 
var potato_inventory_label: Label = null

func _ready() -> void:
	# CRITICAL FIX: Ensure Global is set up and the signal is defined there.
	# If 'Global' is a singleton, this should connect properly.
	if Global.has_signal("pet_selected"):
		Global.pet_selected.connect(_on_pet_selected)
	else:
		push_error("Global singleton must define a 'pet_selected' signal.")
	
	pets_panel = get_parent().get_node_or_null("PetsPanel")
	
	if is_instance_valid(pets_panel):
		var hbox = pets_panel.get_node_or_null("HBoxContainer")
		if is_instance_valid(hbox):
			pass
			# Assuming the labels are named CarrotLabel and PotatoLabel in the scene
			#carrot_inventory_label = hbox.get_node_or_null("CarrotContainer/CarrotLabel") # Updated path based on requested structure
			#potato_inventory_label = hbox.get_node_or_null("PotatoContainer/PotatoLabel") # Updated path based on requested structure

	# Hide the inventory panel initially or when a pet is selected
	if is_instance_valid(pets_panel):
		pets_panel.visible = false 

func _physics_process(_delta: float) -> void:
	if target:
		refresh_pet_info(target) 
	
	# Handle "Go back" or "Cancel" input
	if Input.is_action_just_pressed("cancel"):
		target = null
		if is_instance_valid(info):
			info.visible = false
		
		# SHOW inventory panel when pet info is dismissed
		if is_instance_valid(pets_panel):
			pets_panel.visible = true
			
	# Update UI based on pet selection state
	if target:
		if is_instance_valid(camera):
			camera.zoom = lerp(camera.zoom, Vector2(2.0, 2.0), 8.0 * _delta)
			camera.global_position = lerp(camera.global_position, target.global_position + Vector2(18.0, 0), 8.0 * _delta)
		if is_instance_valid(training_button):
			training_button.visible = false
		if is_instance_valid(info):
			info.visible = true
		
		# HIDE inventory panel when pet stats are shown
		if is_instance_valid(pets_panel):
			pets_panel.visible = false
	else:
		if is_instance_valid(camera):
			camera.zoom = lerp(camera.zoom, Vector2.ONE, 8.0 * _delta)
			camera.global_position = lerp(camera.global_position, Vector2.ZERO, 8.0 * _delta)
		if is_instance_valid(training_button):
			training_button.visible = true
		if is_instance_valid(info):
			info.visible = false
			
		# SHOW inventory panel when no pet is selected (Farm view)
		if is_instance_valid(pets_panel):
			pets_panel.visible = true
			
func reset_camera_view():
	target = null
	if is_instance_valid(info):
		info.visible = false

func refresh_pet_info(pet: Entity) -> void:
	if is_instance_valid(pet):
		update_stats_panel(pet) 
		update_inventory_display(pet.data.inventory)

# NEW FUNCTION: Handles all stats in one VBoxContainer with emojis
func update_stats_panel(pet: Entity) -> void:
	if not is_instance_valid(stats_container):
		return
		
	# Clear previous stats
	for child in stats_container.get_children():
		child.queue_free()

	# --- 1. Level ---
	var level_text = "Lvl: " + str(pet.data.level) + " 👑"
	var level_label = Label.new()
	level_label.text = level_text
	stats_container.add_child(level_label)

	# --- 2. Experience ---
	var current_exp_display = int(pet.data.current_exp / EXP_DISPLAY_SCALE)
	var exp_to_next_level_display = int(pet.data.exp_to_next_level / EXP_DISPLAY_SCALE)
	var exp_text = "EXP: " + str(current_exp_display) + " / " + str(exp_to_next_level_display) + " ✨"
	var exp_label = Label.new()
	exp_label.text = exp_text
	stats_container.add_child(exp_label)

	# --- 3. Wandering ---
	var current_wander_exp_display = int(pet.data.current_wandering_exp / EXP_DISPLAY_SCALE)
	var wander_exp_to_next_level_display = int(pet.data.wandering_exp_to_next_level / EXP_DISPLAY_SCALE)
	var wander_text = "WANDER: Lvl " + str(pet.data.wandering_level) + " (" + str(current_wander_exp_display) + " / " + str(wander_exp_to_next_level_display) + ")" + " 🧭"
	var wander_label = Label.new()
	wander_label.text = wander_text
	stats_container.add_child(wander_label)
	
	# --- 4. Hunger ---
	var hunger_text = "HUNGER: " + str(int(pet.data.hunger)) + " / 100" + " 🍎"
	var hunger_label = Label.new()
	hunger_label.text = hunger_text
	stats_container.add_child(hunger_label)

	# --- 5. Energy ---
	var energy_text = "ENERGY: " + str(int(pet.data.energy)) + " / " + str(int(pet.get_max_energy())) + " ⚡"
	var energy_label = Label.new()
	energy_label.text = energy_text
	stats_container.add_child(energy_label)

func update_inventory_display(inventory: Dictionary) -> void:
	if is_instance_valid(carrot_inventory_label):
		var carrot_count = inventory.get("Carrot", 0)
		carrot_inventory_label.text = "Carrot: " + str(carrot_count)
	
	if is_instance_valid(potato_inventory_label):
		var potato_count = inventory.get("Potato", 0)
		potato_inventory_label.text = "Potato: " + str(potato_count)

# CRITICAL: This function must exist to connect to the signal.
func _on_pet_selected(pet: Entity):
	target = pet
	if is_instance_valid(info):
		info.visible = true
	
	# This line assumes 'farm' is your main farm.gd script node
	if is_instance_valid(farm) and farm.has_method("_on_training_toggled"):
		farm._on_training_toggled(false)
