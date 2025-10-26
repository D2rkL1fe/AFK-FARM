extends CharacterBody2D
class_name Entity

signal interacted(pet_instance: Entity)

@export var data : EntityData
@export var sprite : AnimatedSprite2D
@export var move_timer : Timer
@export var collision_area: Area2D 

const PASSIVE_HUNGER_LOSS_PER_SEC: float = 0.05
const MOVEMENT_ENERGY_COST_PER_SEC: float = 1.5
const MOVEMENT_HUNGER_COST_PER_SEC: float = 0.05
const MOVEMENT_THRESHOLD: float = 15.0
const PASSIVE_ENERGY_REGEN_PER_SEC: float = 3.0
const WANDERING_XP_GAIN_PER_SEC: float = 0.5

const REWARD_COLLECTION_RANGE: float = 20.0 

const MAX_LEVEL: int = 100
const LOW_HUNGER_THRESHOLD: float = 25.0
const LOW_HUNGER_ENERGY_PENALTY: float = 25.0
const STAT_PENALTY_THRESHOLD: float = 50.0
const MOVE_SPEED_BASE: float = 50.0
const MOUSE_FOLLOW_SPEED_BASE: float = 80.0
const EXPEDITION_WANDER_RADIUS: float = 150.0
const EXPEDITION_MEMORY_DISTANCE: float = 60.0
const EXPEDITION_MEMORY_REPULSION: float = 8.0
const EXPEDITION_MEMORY_DECAY_TIME: float = 10.0
const FARM_WANDER_RADIUS: float = 50.0
const FARM_MEMORY_DISTANCE: float = 50.0
const FARM_MEMORY_REPULSION: float = 3.0
const FARM_MEMORY_DECAY_TIME: float = 3.0
const COLLISION_AVOIDANCE_STRENGTH: float = 50.0 
const MIN_FLICKER_VELOCITY: float = 1.0
const MIN_MOVEMENT_VELOCITY: float = 2.0 

enum State { WANDERING, FOLLOWING, IDLE, FOLLOWING_MOUSE, SEEKING_REWARD }
var current_state: State = State.WANDERING

var wander_search_radius: float = FARM_WANDER_RADIUS
var last_wandered_pos: Vector2 = Vector2.ZERO
var last_wandered_time: float = 0.0
var target_pos : Vector2
var leader: CharacterBody2D = null
var follow_offset: Vector2 = Vector2.ZERO
var target_reward: Node2D = null
const LERP_SMOOTHNESS: float = 6.0
const REPULSION_STRENGTH: float = 35.0

func _init():
	randomize_stats()

func _ready() -> void:
	if data == null:
		push_error("EntityData resource is missing! Cannot initialize pet stats.")
		return
	
	if get_tree().get_first_node_in_group("farm_root"):
		wander_search_radius = FARM_WANDER_RADIUS + float(data.wandering_level) * 5.0
	else:
		wander_search_radius = EXPEDITION_WANDER_RADIUS + float(data.wandering_level) * 5.0
		
	move()
	last_wandered_pos = global_position
	last_wandered_time = Time.get_ticks_msec() / 1000.0

func randomize_stats():
	if data == null:
		return
		
	if data.move_speed_multiplier == 0.0:
		data.move_speed_multiplier = randf_range(0.9, 1.1)
	if data.energy_cost_multiplier == 0.0:
		data.energy_cost_multiplier = randf_range(0.9, 1.1)
	if data.exp_gain_multiplier == 0.0:
		data.exp_gain_multiplier = randf_range(0.9, 1.1)

func get_max_energy() -> float:
	if data == null:
		return 100.0
		
	if data.hunger <= LOW_HUNGER_THRESHOLD:
		return 100.0 - LOW_HUNGER_ENERGY_PENALTY
	return 100.0

func get_current_move_speed() -> float:
	if data == null:
		return MOVE_SPEED_BASE
		
	var hunger_factor = 1.0
	var energy_factor = 1.0
	
	if data.hunger < STAT_PENALTY_THRESHOLD:
		hunger_factor = data.hunger / STAT_PENALTY_THRESHOLD 
	
	if data.energy < STAT_PENALTY_THRESHOLD:
		energy_factor = data.energy / STAT_PENALTY_THRESHOLD
		
	var speed_multiplier = min(hunger_factor, energy_factor) * data.move_speed_multiplier
	
	if current_state == State.FOLLOWING_MOUSE:
		return MOUSE_FOLLOW_SPEED_BASE * speed_multiplier
	
	return MOVE_SPEED_BASE * speed_multiplier

func level_up():
	if data == null:
		return
		
	while data.current_exp >= data.exp_to_next_level and data.level < MAX_LEVEL:
		data.current_exp -= data.exp_to_next_level
		data.level += 1
		data.exp_to_next_level = int(data.exp_to_next_level * 1.15) + 30 
	
	if data.level >= MAX_LEVEL:
		data.current_exp = data.exp_to_next_level

func wandering_level_up():
	if data == null:
		return
		
	while data.current_wandering_exp >= data.wandering_exp_to_next_level:
		data.current_wandering_exp -= data.wandering_exp_to_next_level
		data.wandering_level += 1
		data.wandering_exp_to_next_level = int(data.wandering_exp_to_next_level * 1.2)
		
		if get_tree().get_first_node_in_group("farm_root"):
			wander_search_radius = FARM_WANDER_RADIUS + float(data.wandering_level) * 5.0
		else:
			wander_search_radius = EXPEDITION_WANDER_RADIUS + float(data.wandering_level) * 5.0

func eat_food(hunger_restore: float, energy_restore: float) -> void:
	if data == null:
		return
		
	data.hunger = clampf(data.hunger + hunger_restore, 0, 100)
	data.energy = clampf(data.energy + energy_restore, 0, get_max_energy())

func collect(item_name: String, count: int) -> void:
	if data == null:
		return
		
	if data.inventory.has(item_name):
		data.inventory[item_name] += count
	else:
		data.inventory[item_name] = count

func _find_rewards_recursive(node: Node, reward_list: Array[Node2D]) -> void:
	# CRITICAL: Checking for Carrot and Potato class names
	if node is Carrot or node is Potato:
		reward_list.append(node)
	for child in node.get_children():
		_find_rewards_recursive(child, reward_list)

func check_for_rewards():
	var nearest_reward: Node2D = null
	var nearest_distance: float = 9999.0
	
	if current_state != State.WANDERING and current_state != State.IDLE:
		return
	
	var root = get_tree().root.get_child(0)
	var potential_rewards: Array[Node2D] = []
	
	_find_rewards_recursive(root, potential_rewards)
	
	for reward in potential_rewards:
		var distance = global_position.distance_to(reward.global_position)
		
		if distance < nearest_distance and distance <= 150.0:
			nearest_distance = distance
			nearest_reward = reward

	if is_instance_valid(nearest_reward):
		start_seeking_reward(nearest_reward)

func _physics_process(delta: float) -> void:
	if data == null:
		return
		
	data.hunger -= PASSIVE_HUNGER_LOSS_PER_SEC * delta
	data.hunger = clampf(data.hunger, 0, 100)
	
	var max_energy = get_max_energy()
	if data.energy > max_energy:
		data.energy = max_energy
		
	if current_state != State.FOLLOWING_MOUSE:
		data.energy = clampf(data.energy + PASSIVE_ENERGY_REGEN_PER_SEC * delta, 0, max_energy)
		
	if current_state == State.WANDERING or current_state == State.IDLE:
		data.current_wandering_exp += WANDERING_XP_GAIN_PER_SEC * delta
		wandering_level_up()
		
		var memory_distance = EXPEDITION_MEMORY_DISTANCE
		if get_tree().get_first_node_in_group("farm_root"):
			memory_distance = FARM_MEMORY_DISTANCE
			
		if global_position.distance_to(last_wandered_pos) >= memory_distance:
			last_wandered_pos = global_position
			last_wandered_time = Time.get_ticks_msec() / 1000.0
		
		check_for_rewards()
	
	if current_state == State.SEEKING_REWARD:
		if is_instance_valid(target_reward):
			target_pos = target_reward.global_position
			
			if global_position.distance_to(target_pos) <= REWARD_COLLECTION_RANGE:
				if target_reward.has_method("collect_item"):
					target_reward.collect_item(self)
				move()
			
		else:
			move()
			
	var current_move_speed: float = get_current_move_speed()
	
	if current_state == State.FOLLOWING:
		target_pos = leader.global_position + follow_offset
	
	var direction = (target_pos - global_position).normalized()
	
	sprite.z_index = int(global_position.y) + 1000 
	
	var desired_velocity: Vector2
	var is_moving_to_target: bool = global_position.distance_to(target_pos) > MOVEMENT_THRESHOLD or current_state == State.SEEKING_REWARD
	
	if is_moving_to_target:
		var avoidance_force = calculate_avoidance_force()
		var memory_force = calculate_memory_force()
		
		desired_velocity = direction * current_move_speed + avoidance_force + memory_force
		
		if current_state == State.WANDERING:
			var random_deviation = Vector2.from_angle(randf_range(-PI/8, PI/8))
			desired_velocity = desired_velocity.rotated(random_deviation.angle())
		
		if current_state == State.SEEKING_REWARD:
			velocity = desired_velocity
		else:
			velocity = lerp(velocity, desired_velocity, LERP_SMOOTHNESS * delta)
	else:
		velocity = lerp(velocity, Vector2.ZERO, LERP_SMOOTHNESS * delta)

	if velocity.length() > MIN_MOVEMENT_VELOCITY: 
		sprite.play("move")
		if velocity.x > MIN_FLICKER_VELOCITY:
			sprite.flip_h = true
		elif velocity.x < -MIN_FLICKER_VELOCITY:
			sprite.flip_h = false
	else:
		sprite.play("idle")
	
	move_and_slide()
	
	if current_state == State.FOLLOWING_MOUSE:
		if data.energy <= 5:
			stop_following()
		elif velocity.length() > MIN_MOVEMENT_VELOCITY:
			data.energy = clampf(data.energy - MOVEMENT_ENERGY_COST_PER_SEC * data.energy_cost_multiplier * delta, 0, max_energy)
			data.hunger = clampf(data.hunger - MOVEMENT_HUNGER_COST_PER_SEC * delta, 0, 100)

func move():
	current_state = State.WANDERING
	
	var search_range = wander_search_radius 
	
	target_pos = global_position + Vector2(randf_range(-search_range, search_range), randf_range(-search_range, search_range))
	
	if get_tree().get_first_node_in_group("farm_root"):
		target_pos.x = clampf(target_pos.x, -100.0, 100.0)
		target_pos.y = clampf(target_pos.y, -100.0, 100.0)

	move_timer.wait_time = randf_range(2.0, 5.0)
	move_timer.start()

func start_following(new_leader: CharacterBody2D):
	current_state = State.FOLLOWING
	leader = new_leader
	follow_offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	move_timer.stop()

func start_following_mouse(pos: Vector2):
	current_state = State.FOLLOWING_MOUSE
	target_pos = pos

func stop_following():
	current_state = State.WANDERING
	move()

func start_seeking_reward(reward: Node2D):
	current_state = State.SEEKING_REWARD
	target_reward = reward
	velocity = Vector2.ZERO
	move_timer.stop()

func _on_move_timer_timeout() -> void:
	if current_state == State.WANDERING:
		move()
	
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if current_state == State.FOLLOWING_MOUSE:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		interacted.emit(self)
		get_viewport().set_input_as_handled()

func calculate_avoidance_force() -> Vector2:
	var repulsion_force = Vector2.ZERO
	if collision_area == null:
		return Vector2.ZERO
	
	var overlapping_bodies = collision_area.get_overlapping_bodies()

	for body in overlapping_bodies:
		if body is Entity and body != self:
			var vector_away = (global_position - body.global_position).normalized()
			var distance = global_position.distance_to(body.global_position)
			var weight = COLLISION_AVOIDANCE_STRENGTH / max(1.0, distance) 
			repulsion_force += vector_away * weight

	return repulsion_force
	
func calculate_memory_force() -> Vector2:
	if data == null or current_state != State.WANDERING:
		return Vector2.ZERO
		
	var memory_decay_time = EXPEDITION_MEMORY_DECAY_TIME
	var memory_repulsion = EXPEDITION_MEMORY_REPULSION
	
	if get_tree().get_first_node_in_group("farm_root"):
		memory_decay_time = FARM_MEMORY_DECAY_TIME
		memory_repulsion = FARM_MEMORY_REPULSION

	var time_since_last_visit = (Time.get_ticks_msec() / 1000.0) - last_wandered_time
	
	if time_since_last_visit < memory_decay_time:
		var memory_strength = 1.0 - (time_since_last_visit / memory_decay_time)
		var vector_away = (global_position - last_wandered_pos).normalized()
		var distance_factor = 1.0 / max(1.0, global_position.distance_to(last_wandered_pos) / 100.0)
		
		var memory_force = vector_away * memory_strength * distance_factor * memory_repulsion
		return memory_force
	
	return Vector2.ZERO
