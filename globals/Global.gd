# Global.gd
extends Node
# Signals
signal pet_selected(pet)
signal request_expedition(pet, tile_id, duration_seconds)
signal ui_action(action_name : String, pet)

# Basic save keys
const SAVE_PATH := "user://save_game.json"

func select_pet(pet):
	emit_signal("pet_selected", pet)

func request_explore(pet, tile_id, duration_seconds):
	emit_signal("request_expedition", pet, tile_id, duration_seconds)

func send_ui_action(action_name: String, pet):
	emit_signal("ui_action", action_name, pet)
