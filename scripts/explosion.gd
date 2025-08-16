extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
var damage


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

# called by GameManager when InputEvent.action_pressed("paused") == true
func pause():
	animated_sprite.process_mode = Node.PROCESS_MODE_ALWAYS if animated_sprite.process_mode==Node.PROCESS_MODE_DISABLED else Node.PROCESS_MODE_DISABLED
