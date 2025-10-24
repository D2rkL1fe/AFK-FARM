extends Node

# Music
const MEME = preload("uid://eiwbv47yxsb0")

# ohh
@export var audio_player : AudioStreamPlayer

func play_music(music):
	audio_player.stream = music
	audio_player.play()
