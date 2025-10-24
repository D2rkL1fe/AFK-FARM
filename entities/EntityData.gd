class_name EntityData
extends Resource

@export var entity_name : String = "Entity"

const MAX_LEVEL : int = 10
var level : int = 1

var experience : int = 0

@export var hunger : int = 100

@export var max_energy : int = 100
var energy : int = 100

func feed():
	hunger = max(hunger + 20, 100)
