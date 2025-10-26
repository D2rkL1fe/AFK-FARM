extends Node2D
class_name Carrot 

@export var collect_item_name: String = "Carrot" 
@export var collection_value: int = 1

func collect_item(collector: Entity) -> void:
	if is_instance_valid(collector):
		collector.collect(collect_item_name, collection_value)
		
	queue_free()
