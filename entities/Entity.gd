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
const MOVEMENT_THRESHOLD: float = 5.0

const MAX_LEVEL: int = 100
const LOW_HUNGER_THRESHOLD: float = 25.0
const LOW_HUNGER_ENERGY_PENALTY: float = 50.0
const STAT_PENALTY_THRESHOLD: float = 50.0
const MOVE_SPEED_BASE: float = 25.0
const MOUSE_FOLLOW_SPEED_BASE: float = 60.0

var current_exp: int = 0
var exp_to_next_level: int = 50
var level: int = 1
var current_hunger: float = 100.0
var current_energy: float = 100.0

var move_speed_multiplier: float
var energy_cost_multiplier: float
var exp_gain_multiplier: float

enum State { WANDERING, FOLLOWING, IDLE, FOLLOWING_MOUSE }
var current_state: State = State.WANDERING

var target_pos : Vector2
var leader: CharacterBody2D = null
var follow_offset: Vector2 = Vector2.ZERO

const LERP_SMOOTHNESS: float = 4.0
const REPULSION_STRENGTH: float = 35.0

func _init():
	randomize_stats()

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
		exp_to_next_level = int(exp_to_next_level * 1.2) + 50
		print("Pet leveled up to ", level, "! Next EXP needed: ", exp_to_next_level)
	
	if level >= MAX_LEVEL:
		current_exp = exp_to_next_level

func _physics_process(delta: float) -> void:
	
	current_hunger -= PASSIVE_HUNGER_LOSS_PER_SEC * delta
	current_hunger = clampf(current_hunger, 0, 100)
	
	var max_energy = get_max_energy()
	if current_energy > max_energy:
		current_energy = max_energy
	
	var current_move_speed: float = get_current_move_speed()
	
	if current_state == State.FOLLOWING:
		target_pos = leader.global_position + follow_offset
	
	var direction = (target_pos - global_position).normalized()
	
	sprite.z_index = int(global_position.y)
	
	var desired_velocity: Vector2
	var is_moving: bool = global_position.distance_to(target_pos) > 5.0
	
	if is_moving:
		desired_velocity = direction * current_move_speed + calculate_avoidance_force()
		sprite.play("move")
		sprite.flip_h = desired_velocity.x > 0
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
	target_pos = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
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
			var weight = REPULSION_STRENGTH / max(1.0, distance)
			repulsion_force += vector_away * weight

	return repulsion_force
