extends Node2D

var tomato = preload("res://scenes/dragoons/regularDragoon/tomatoGoon/tomato.tscn")
var tomatoDamage = 1
var pathName
var currTargets = []
var curr

func _ready():
	var animated_sprite = $AnimatedSprite2D
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.connect("frame_changed", Callable(self, "_on_animated_sprite_frame_changed"))
		animated_sprite.connect("animation_finished", Callable(self, "_on_animated_sprite_animation_finished"))

func _process(delta):
	if is_instance_valid(curr):
		self.look_at(curr.global_position)
	else:
		# If the current target is no longer valid, stop the animation
		# and clear out any remaining projectiles.
		$AnimatedSprite2D.play("idle")
		#for i in get_node("TomatoContainer").get_child_count():
		#	get_node("TomatoContainer").get_child(i).queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		var tempArray = []
		currTargets = get_node("DetectionArea").get_overlapping_bodies()
		
		for i in currTargets:
			if "Enemy" in i.name:
				tempArray.append(i)
				
		var currTarget = null
		
		for i in tempArray:
			if currTarget == null:
				currTarget = i.get_node("../")
			else:
				if i.get_parent().get_progress() > currTarget.get_progress():
					currTarget = i.get_node("../")
					
		curr = currTarget
		
		if $AnimatedSprite2D.animation != "shoot":
			$AnimatedSprite2D.play("shoot")

func _on_animated_sprite_frame_changed():
	# Check if the animation is 'shoot' and on the correct frame (4th frame is index 3)
	if $AnimatedSprite2D.animation == "shoot" and $AnimatedSprite2D.frame == 3:
		# CRUCIAL: Check if the target is still valid BEFORE trying to use it.
		if is_instance_valid(curr):
			var tempTomato = tomato.instantiate()
			tempTomato.tomatoDamage = tomatoDamage
			tempTomato.target_node = curr
			get_node("TomatoContainer").add_child(tempTomato)
			tempTomato.global_position = $Aim.global_position
		else:
			# If the target is no longer valid, stop the animation and reset to idle.
			$AnimatedSprite2D.play("idle")


func _on_animated_sprite_animation_finished():
	if is_instance_valid(curr):
		$AnimatedSprite2D.play("shoot")
	else:
		$AnimatedSprite2D.play("idle")

func _on_detection_area_body_exited(body: Node2D) -> void:
	currTargets = get_node("DetectionArea").get_overlapping_bodies()
	if currTargets.is_empty():
		$AnimatedSprite2D.play("idle")
