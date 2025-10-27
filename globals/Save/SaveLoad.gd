extends Node

const save_location = "user://SaveFile.tres"

var SaveFileData : SaveDataResource = SaveDataResource.new()

var save_timer : Timer

func _ready() -> void:
	_load()
	
	# timer to save data periodically
	save_timer = Timer.new()
	save_timer.wait_time = 15.0
	save_timer.autostart = true
	save_timer.timeout.connect(_save)
	
	get_tree().root.add_child.call_deferred(save_timer)

func _save():
	print("Saving data!")
	ResourceSaver.save(SaveFileData, save_location)

func _load():
	print("Loading data!")
	if FileAccess.file_exists(save_location):
		SaveFileData = ResourceLoader.load(save_location).duplicate(true)
