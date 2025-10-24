class_name SelectComponent
extends Area2D


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		Global.pet_selected.emit(get_parent())
	elif event is InputEventMouseButton:
		Global.pet_selected.emit(get_parent())
