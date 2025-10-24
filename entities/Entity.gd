extends CharacterBody2D
class_name Entity

signal interacted(pet_instance: Entity)

@export var data : EntityData = EntityData.new()

@export var sprite : AnimatedSprite2D
@export var move_timer : Timer

var target_pos : Vector2

func _ready() -> void:
	move()

func _physics_process(delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	
	sprite.z_index = int(global_position.y)
	
	if global_position.distance_to(target_pos) > 5.0:
		sprite.play("move")
		sprite.flip_h = direction.x > 0
		
		velocity = lerp(velocity, direction * 25, 4.0 * delta)
	else:
		sprite.play("idle")
		velocity = lerp(velocity, Vector2.ZERO, 4.0 * delta)
	
	move_and_slide()

func move():
	target_pos = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	target_pos = target_pos.clamp(Vector2(-75, -75), Vector2(75, 75))
	
	move_timer.wait_time = randf_range(2.0, 5.0)
	move_timer.start()

func _on_move_timer_timeout() -> void:
	move()
	
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		interacted.emit(self)
		get_viewport().set_input_as_handled()
