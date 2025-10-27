class_name SelectComponent
extends Area2D


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		Global.pet_selected.emit(get_parent())
		SoundPlayer.play_sound(SoundPlayer.PET_SELECT)
		get_parent().animator.play("click")
	elif event is InputEventMouseButton and event.is_pressed():
		Global.pet_selected.emit(get_parent())
		SoundPlayer.play_sound(SoundPlayer.PET_SELECT)
		get_parent().animator.play("click")
