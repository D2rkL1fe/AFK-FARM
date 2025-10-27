extends Control

@export var carrot_label : Label
@export var potato_label : Label

func activate(carrot, potato):
	visible = true
	
	carrot_label.text = str(carrot)
	potato_label.text = str(potato)


func _on_close_pressed() -> void:
	visible = false
