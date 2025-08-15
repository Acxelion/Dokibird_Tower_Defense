extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Connect a signal to know when the animation has finished.
	await get_tree().create_timer(4).timeout
	queue_free()
