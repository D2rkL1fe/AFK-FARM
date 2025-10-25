extends CharacterBody2D
class_name Entity

signal interacted(pet_instance: Entity)

@export var data : EntityData = EntityData.new()
@export var sprite : AnimatedSprite2D
@export var move_timer : Timer
@export var collision_area: Area2D

enum State { WANDERING, FOLLOWING, IDLE, FOLLOWING_MOUSE }
var current_state: State = State.WANDERING

var target_pos : Vector2
var leader: CharacterBody2D = null
var follow_offset: Vector2 = Vector2.ZERO

const MOVE_SPEED: float = 25.0
const MOUSE_FOLLOW_SPEED: float = 120.0
const LERP_SMOOTHNESS: float = 4.0
const REPULSION_STRENGTH: float = 35.0

func _ready() -> void:
	move()

func _physics_process(delta: float) -> void:
	var current_move_speed: float = MOVE_SPEED
	
	if current_state == State.FOLLOWING:
		target_pos = leader.global_position + follow_offset
	elif current_state == State.FOLLOWING_MOUSE:
		current_move_speed = MOUSE_FOLLOW_SPEED
	
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
