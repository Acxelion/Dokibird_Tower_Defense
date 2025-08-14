extends CharacterBody2D

@export var speed: int = 1000
@export var health: int = 1

@onready var parent = get_parent()

func _process(delta):
	parent.progress = (parent.progress + speed * delta)
