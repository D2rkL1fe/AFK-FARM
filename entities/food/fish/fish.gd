extends Node2D
class_name Fish

signal fish_clicked(fish_instance)

func _ready():
	var farm_node = get_tree().get_first_node_in_group("farm_root")
	if farm_node:
		fish_clicked.connect(farm_node._on_fish_clicked)

func _on_body_entered(body: Node2D):
	if body is Entity:
		fish_clicked.emit(self)
		queue_free()
