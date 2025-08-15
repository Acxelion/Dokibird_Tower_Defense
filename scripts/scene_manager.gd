extends CanvasLayer

signal scene_changed()

@onready var anim = $AnimationPlayer
@onready var black_screen = $BlackScreen

func change_scene(path, delay=0.5):
	anim.play("fade")
	await anim.animation_finished
	assert(get_tree().change_scene_to_file(path) == OK)
	anim.play_backwards("fade")
	scene_changed.emit()
	
