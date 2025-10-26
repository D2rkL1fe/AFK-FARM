extends Control

func transition():
	MusicPlayer.play_music(MusicPlayer.LOFI)
	
	Global.transition("res://scenes/farm/farm.tscn")
