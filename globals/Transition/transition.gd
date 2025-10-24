extends CanvasLayer

@export var animator : AnimationPlayer

func start(scene):
	animator.play("transition")
	SoundPlayer.play_sound(SoundPlayer.WHOOSH_IN)
	
	await animator.animation_finished
	
	get_tree().change_scene_to_file(scene)
	
	animator.play_backwards("transition")
	SoundPlayer.play_sound(SoundPlayer.WHOOSH_OUT)
	
	await animator.animation_finished
