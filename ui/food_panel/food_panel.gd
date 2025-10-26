extends PanelContainer

@export var carrot_label : Label
@export var potato_label : Label

func _ready() -> void:
	_on_food_changed()
	
	Stats.food_changed.connect(_on_food_changed)

func _on_food_changed():
	carrot_label.text = str(Stats.carrot_amount)
	potato_label.text = str(Stats.potato_amount)
