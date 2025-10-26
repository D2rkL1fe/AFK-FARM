extends Node2D
class_name Potato

signal potato_clicked(food_instance)

func _ready():
	var farm_node = get_tree().get_first_node_in_group("farm_root")
	if farm_node:
		potato_clicked.connect(farm_node._on_food_clicked)

func _on_body_entered(body: Node2D):
	if body is Entity:
		potato_clicked.emit(self)
		queue_free()
