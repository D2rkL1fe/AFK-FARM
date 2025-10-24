# Global.gd
extends Node

# 
var transitioning : bool = false

# Signals
signal pet_selected(pet)

signal request_expedition(pet, tile_id, duration_seconds)
signal ui_action(action_name : String, pet)

# Basic save keys
const SAVE_PATH := "user://save_game.json"

func request_explore(pet, tile_id, duration_seconds):
	emit_signal("request_expedition", pet, tile_id, duration_seconds)

func send_ui_action(action_name: String, pet):
	emit_signal("ui_action", action_name, pet)

# transition handler
func transition(scene):
	if transitioning:
		return
	
	transitioning = true
	await Transition.start(scene)
	transitioning = false
