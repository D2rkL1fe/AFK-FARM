extends Control

@export var carrot_label : Label
@export var potato_label : Label

func activate():
	visible = true
	
	carrot_label.text = str(Stats.carrot_amount)
	potato_label.text = str(Stats.potato_amount)


func _on_close_pressed() -> void:
	visible = false
