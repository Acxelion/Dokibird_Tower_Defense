extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
var damage = 1


func _ready() -> void:
	if animated_sprite:
		animated_sprite.play("default")
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))


func _on_animation_finished():
	# Delete the explosion scene once the animation is complete.
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		body.get_damage(damage)
