extends Node2D
class_name Potato

@export var collect_item_name: String = "Potato"
@export var collection_value: int = 1
@export var hunger_restore_all: float = 10.0
@export var energy_restore_all: float = 5.0 

func collect_item(collector: Entity) -> void:
	Stats.potato_amount += 1
	Stats.food_changed.emit()
	
	SoundPlayer.play_sound(SoundPlayer.PICK_UP)
	
	queue_free()
