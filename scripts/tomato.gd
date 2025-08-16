extends CharacterBody2D

var target_node: Node2D  # Will store a direct reference to the enemy
var speed = 1000
var tomatoDamage

var tomatoImpact = preload("res://scenes/dragoons/regularDragoon/tomatoGoon/tomato_impact.tscn")
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.play("default")

func _physics_process(delta):
	# skip body/movement of tomato if game is paused
	if not Globals.paused_status:
		# Before using target_node, check if it's still valid.
		# If the target is gone, the projectile should just disappear.
		if not is_instance_valid(target_node):
			queue_free()
			return
		
		var target_position = target_node.global_position
		
		velocity = global_position.direction_to(target_position) * speed
		
		look_at(target_position)
		
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		
		# Instantiate the new scene.
		var impact_effect = tomatoImpact.instantiate()
		
		# Set the new scene's position to the tomato's current position.
		impact_effect.global_position = global_position
		
		# Add the new scene to the game world.
		# A good place is the parent of the tomato, which is likely the game scene.
		get_parent().add_child(impact_effect)
		
		body.get_damage(tomatoDamage)
		
		var anim_player = impact_effect.get_node("AnimationPlayer")
		if anim_player:
			# Play the animation we created.
			anim_player.play("fade")
		
		queue_free()

# called by GameManager when InputEvent.action_pressed("paused") == true
func pause():
	pass
	#self.process_mode = Node.PROCESS_MODE_ALWAYS if self.process_mode==Node.PROCESS_MODE_DISABLED else Node.PROCESS_MODE_DISABLED
