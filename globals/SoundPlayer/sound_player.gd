extends Node

# SFX
const WHOOSH_IN = preload("uid://dsqismlkhmys1")
const WHOOSH_OUT = preload("uid://cpgwlss0bsf8v")

const POWER_UP = preload("uid://cp8pdj6vg0uem")

# ahh
var audio_players

func _ready() -> void:
	audio_players = get_children()

func play_sound(sound):
	for audio_player in audio_players:
		if !audio_player.playing:
			audio_player.stream = sound
			audio_player.pitch_scale = randf_range(0.95, 1.05)
			
			audio_player.play()
			
			break
