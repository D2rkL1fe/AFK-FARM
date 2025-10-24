extends Camera2D
class_name CameraController

const FOCUS_TIMEOUT_SEC: float = 5.0 

var focused_target: Node2D = null
var focus_timer: Timer

const WIDE_ZOOM: Vector2 = Vector2(1.0, 1.0) # Reset zoom to 1.0 (original value)
const FOCUSED_UI_ZOOM: Vector2 = Vector2(2.0, 2.0)
const FOCUSED_UI_OFFSET: Vector2 = Vector2(18.0, 0)
const LERP_SPEED: float = 2.0 # Smoother follow speed

func _ready() -> void:
	focus_timer = Timer.new()
	focus_timer.wait_time = FOCUS_TIMEOUT_SEC
	focus_timer.one_shot = true
	focus_timer.timeout.connect(_on_focus_timeout)
	add_child(focus_timer)

	zoom = WIDE_ZOOM
	
	# Connect signals from Farm and FarmUI
	if get_tree().get_first_node_in_group("Farm"):
		var farm_node = get_tree().get_first_node_in_group("Farm")
		farm_node.pet_interacted.connect(set_pet_focus)
		farm_node.void_clicked.connect(reset_focus)

	if get_tree().get_first_node_in_group("FarmUI"):
		var ui_node = get_tree().get_first_node_in_group("FarmUI")
		ui_node.reset_camera_view_signal.connect(reset_focus)
		ui_node.focus_pet_signal.connect(set_pet_focus)

func _process(delta: float) -> void:
	if focused_target:
		var target_zoom = FOCUSED_UI_ZOOM
		var target_pos = focused_target.global_position + FOCUSED_UI_OFFSET

		global_position = global_position.lerp(target_pos, LERP_SPEED * delta)
		zoom = zoom.lerp(target_zoom, LERP_SPEED * delta)
	else:
		global_position = global_position.lerp(Vector2.ZERO, LERP_SPEED * delta)
		zoom = zoom.lerp(WIDE_ZOOM, LERP_SPEED * delta)

func set_pet_focus(new_target: Node2D) -> void:
	focused_target = new_target
	focus_timer.start()

func reset_focus() -> void:
	focus_timer.stop()
	focused_target = null

func _on_focus_timeout() -> void:
	focused_target = null
