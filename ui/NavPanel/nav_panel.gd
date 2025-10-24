extends PanelContainer

func _on_farm_pressed() -> void:
	if get_tree().current_scene.name != "Farm":
		Global.transition("res://scenes/farm/farm.tscn")

func _on_expedition_pressed() -> void:
	if get_tree().current_scene.name != "Expedition":
		Global.transition("res://scenes/expedition/expedition.tscn")
