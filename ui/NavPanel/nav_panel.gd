extends PanelContainer

func _on_farm_pressed() -> void:
	if get_tree().current_scene.name != "Farm":
		get_tree().change_scene_to_file("res://scenes/farm/farm.tscn")

func _on_expedition_pressed() -> void:
	if get_tree().current_scene.name != "Expedition":
		get_tree().change_scene_to_file("res://scenes/expedition/expedition.tscn")
