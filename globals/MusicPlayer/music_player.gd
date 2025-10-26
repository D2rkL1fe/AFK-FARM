extends Node

# Music
const HARDBASS = preload("uid://cftmrn277g681")
const LOFI = preload("uid://b63fen0aqvc6p")

# ohh
@export var audio_player : AudioStreamPlayer

func play_music(music):
	audio_player.stream = music
	audio_player.play()
