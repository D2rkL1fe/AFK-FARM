extends CharacterBody2D
class_name Entity

signal interacted(pet_instance: Entity)

@export var data : EntityData = EntityData.new()
@export var sprite : AnimatedSprite2D
@export var move_timer : Timer
@export var collision_area: Area2D

const PASSIVE_HUNGER_LOSS_PER_SEC: float = 0.05
const MOVEMENT_ENERGY_COST_PER_SEC: float = 3.0
const MOVEMENT_HUNGER_COST_PER_SEC: float = 0.1
const MOVEMENT_THRESHOLD: float = 15.0
const PASSIVE_ENERGY_REGEN_PER_SEC: float = 2.0
const WANDERING_XP_GAIN_PER_SEC: float = 0.5
const BASE_WANDERING_EXP_TO_NEXT_LEVEL: int = 100

const MAX_LEVEL: int = 100
const LOW_HUNGER_THRESHOLD: float = 25.0
const LOW_HUNGER_ENERGY_PENALTY: float = 50.0
const STAT_PENALTY_THRESHOLD: float = 50.0
const MOVE_SPEED_BASE: float = 25.0
const MOUSE_FOLLOW_SPEED_BASE: float = 60.0
const REWARD_COLLECTION_RANGE: float = 20.0

const MEMORY_DECAY_TIME: float = 10.0
const MEMORY_UPDATE_DISTANCE: float = 30.0
const COLLISION_AVOIDANCE_STRENGTH: float = 50.0 
const MIN_FLICKER_VELOCITY: float = 1.0

var current_exp: int = 0
var exp_to_next_level: int = 30
var level: int = 1
var current_hunger: float = 100.0
var current_energy: float = 100.0

var wandering_level: int = 1
var current_wandering_exp: float = 0.0
var wandering_exp_to_next_level: int = BASE_WANDERING_EXP_TO_NEXT_LEVEL
var wander_search_radius: float = 50.0
var wander_radius_base: float = 50.0

var last_wandered_pos: Vector2 = Vector2.ZERO
var last_wandered_time: float = 0.0

var move_speed_multiplier: float
var energy_cost_multiplier: float
var exp_gain_multiplier: float

enum State { WANDERING, FOLLOWING, IDLE, FOLLOWING_MOUSE, SEEKING_REWARD }
var current_state: State = State.WANDERING

var target_pos : Vector2
var leader: CharacterBody2D = null
var follow_offset: Vector2 = Vector2.ZERO
var target_reward: Node2D = null

const LERP_SMOOTHNESS: float = 4.0
const REPULSION_STRENGTH: float = 35.0

func _init():
	randomize_stats()

func _ready() -> void:
	move()
	last_wandered_pos = global_position
	last_wandered_time = Time.get_ticks_msec() / 1000.0

func randomize_stats():
	move_speed_multiplier = randf_range(0.7, 1.3)
	energy_cost_multiplier = randf_range(0.7, 1.3)
	exp_gain_multiplier = randf_range(0.8, 1.5)

func get_max_energy() -> float:
	if current_hunger <= LOW_HUNGER_THRESHOLD:
		return 100.0 - LOW_HUNGER_ENERGY_PENALTY
	return 100.0

func get_current_move_speed() -> float:
	var hunger_factor = 1.0
	var energy_factor = 1.0
	
	if current_hunger < STAT_PENALTY_THRESHOLD:
		hunger_factor = current_hunger / STAT_PENALTY_THRESHOLD 
	
	if current_energy < STAT_PENALTY_THRESHOLD:
		energy_factor = current_energy / STAT_PENALTY_THRESHOLD
		
	var speed_multiplier = min(hunger_factor, energy_factor) * move_speed_multiplier
	
	if current_state == State.FOLLOWING_MOUSE:
		return MOUSE_FOLLOW_SPEED_BASE * speed_multiplier
	
	return MOVE_SPEED_BASE * speed_multiplier

func level_up():
	while current_exp >= exp_to_next_level and level < MAX_LEVEL:
		current_exp -= exp_to_next_level
		level += 1
		exp_to_next_level = int(exp_to_next_level * 1.15) + 30 
	
	if level >= MAX_LEVEL:
		current_exp = exp_to_next_level

func wandering_level_up():
	while current_wandering_exp >= wandering_exp_to_next_level:
		current_wandering_exp -= wandering_exp_to_next_level
		wandering_level += 1
		wandering_exp_to_next_level = int(wandering_exp_to_next_level * 1.2)
		wander_search_radius = wander_radius_base + float(wandering_level) * 5.0

func eat_food(hunger_restore: float, energy_restore: float) -> void:
	current_hunger = clampf(current_hunger + hunger_restore, 0, 100)
	current_energy = clampf(current_energy + energy_restore, 0, get_max_energy())

func check_for_rewards():
	var nearest_reward: Node2D = null
	var nearest_distance: float = 9999.0
	
	if current_state != State.WANDERING and current_state != State.IDLE:
		return
	
	if collision_area == null:
		return
	
	var boosted_range: float = 0.0
	if wandering_level <= 5:
		boosted_range = 100.0
	
	var overlapping_areas = collision_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.get_parent() is Fish or area.get_parent() is Potato:
			var reward_parent = area.get_parent()
			var distance = global_position.distance_to(reward_parent.global_position)
			
			if distance < nearest_distance and (distance <= wander_search_radius or distance <= boosted_range):
				nearest_distance = distance
				nearest_reward = reward_parent

	if is_instance_valid(nearest_reward):
		start_seeking_reward(nearest_reward)

func _physics_process(delta: float) -> void:
	
	current_hunger -= PASSIVE_HUNGER_LOSS_PER_SEC * delta
	current_hunger = clampf(current_hunger, 0, 100)
	
	var max_energy = get_max_energy()
	if current_energy > max_energy:
		current_energy = max_energy
		
	if current_state != State.FOLLOWING_MOUSE:
		current_energy = clampf(current_energy + PASSIVE_ENERGY_REGEN_PER_SEC * delta, 0, max_energy)
		
	if current_state == State.WANDERING or current_state == State.IDLE:
		current_wandering_exp += WANDERING_XP_GAIN_PER_SEC * delta
		wandering_level_up()
		if global_position.distance_to(last_wandered_pos) >= MEMORY_UPDATE_DISTANCE:
			last_wandered_pos = global_position
			last_wandered_time = Time.get_ticks_msec() / 1000.0
		
		check_for_rewards()
	
	if current_state == State.SEEKING_REWARD:
		if is_instance_valid(target_reward):
			target_pos = target_reward.global_position
			
			if global_position.distance_to(target_pos) <= REWARD_COLLECTION_RANGE:
				move()
			
		else:
			move()
			
	var current_move_speed: float = get_current_move_speed()
	
	if current_state == State.FOLLOWING:
		target_pos = leader.global_position + follow_offset
	
	var direction = (target_pos - global_position).normalized()
	
	sprite.z_index = int(global_position.y) + 1000 
	
	var desired_velocity: Vector2
	var is_moving: bool = global_position.distance_to(target_pos) > MOVEMENT_THRESHOLD or current_state == State.SEEKING_REWARD
	
	if is_moving:
		var avoidance_force = calculate_avoidance_force()
		var memory_force = calculate_memory_force()
		
		desired_velocity = direction * current_move_speed + avoidance_force + memory_force
		
		sprite.play("move")
		
		if current_state == State.WANDERING:
			var random_deviation = Vector2.from_angle(randf_range(-PI/8, PI/8))
			desired_velocity = desired_velocity.rotated(random_deviation.angle())
		
		if velocity.x > MIN_FLICKER_VELOCITY:
			sprite.flip_h = true
		elif velocity.x < -MIN_FLICKER_VELOCITY:
			sprite.flip_h = false
		
		if current_state == State.SEEKING_REWARD:
			velocity = desired_velocity
		else:
			velocity = lerp(velocity, desired_velocity, LERP_SMOOTHNESS * delta)
	else:
		sprite.play("idle")
		velocity = lerp(velocity, Vector2.ZERO, LERP_SMOOTHNESS * delta)
	
	move_and_slide()
	
	if current_state == State.FOLLOWING_MOUSE and velocity.length() > MOVEMENT_THRESHOLD:
		current_energy = clampf(current_energy - MOVEMENT_ENERGY_COST_PER_SEC * energy_cost_multiplier * delta, 0, max_energy)
		current_hunger = clampf(current_hunger - MOVEMENT_HUNGER_COST_PER_SEC * delta, 0, 100)

func move():
	current_state = State.WANDERING
	
	var search_range = wander_search_radius 
	
	target_pos = global_position + Vector2(randf_range(-search_range, search_range), randf_range(-search_range, search_range))
	target_pos = target_pos.clamp(Vector2(-75, -75), Vector2(75, 75))
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
	if current_state != State.WANDERING:
		return Vector2.ZERO
		
	var time_since_last_visit = (Time.get_ticks_msec() / 1000.0) - last_wandered_time
	
	if time_since_last_visit < MEMORY_DECAY_TIME:
		var memory_strength = 1.0 - (time_since_last_visit / MEMORY_DECAY_TIME)
		var vector_away = (global_position - last_wandered_pos).normalized()
		var distance_factor = 1.0 / max(1.0, global_position.distance_to(last_wandered_pos) / 100.0)
		
		var memory_repulsion = vector_away * memory_strength * distance_factor * 25.0
		return memory_repulsion
	
	return Vector2.ZERO
