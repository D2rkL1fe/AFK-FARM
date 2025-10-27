extends Node

func _ready() -> void:
	if get_parent() is Button:
		var button : Button = get_parent()
		
		button.pressed.connect(_on_pressed)
		button.mouse_entered.connect(_on_hover)

func _on_pressed():
	SoundPlayer.play_sound(SoundPlayer.PRESSED)

func _on_hover():
	SoundPlayer.play_sound(SoundPlayer.HOVER)
