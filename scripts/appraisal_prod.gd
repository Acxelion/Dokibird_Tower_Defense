extends Node2D

# We need to pre-load the FloatingText scene so we can create instances of it.
# Make sure the path is correct.
@export var floating_text_scene: PackedScene = preload("res://scenes/dragoons/dokiumProd/appraisalProd/floating_text.tscn")

# Signal to tell the main game scene to update the currency.
signal add_currency(amount)

# corresponding string key in Data.TURRETS
const KEY: String = "appraisal_prod"

# money earned per timer.timeout
@onready var reward: int = Data.TURRETS[KEY].reward

# Called when the node and its children are ready.
func _ready():
	# Play the animation.
	var animated_sprite = $AnimatedSprite2D
	if animated_sprite:
		animated_sprite.play("default")
		
	# Connect and start the timer.
	var timer = $Timer
	if timer:
		timer.connect("timeout", _on_timer_timeout)
			
		timer.start()

func _on_timer_timeout() -> void:
	# 1. Emit the signal to add currency to the main game.
	emit_signal("add_currency", reward)
	
	# 2. Create the floating text effect.
	if floating_text_scene:
		# Create a new instance of our FloatingText scene.
		var floating_text_instance = floating_text_scene.instantiate()
		
		# Set the text to "+1" (optional, you can also set it in the scene itself).
		# We can get the label node by using get_node("Label").
		var label = floating_text_instance.get_node("Label")
		if label:
			label.text = "+" + str(reward)
			
		# Set the position of the floating text to be at the tower's location.
		# We add it to the scene tree as a sibling of the tower.
		get_parent().add_child(floating_text_instance)
		var offset = Vector2(50, -80)
		floating_text_instance.global_position = self.global_position + offset
		
		# We get the AnimationPlayer from our new instance.
		var anim_player = floating_text_instance.get_node("AnimationPlayer")
		if anim_player:
			# Play the animation we created.
			anim_player.play("float_and_fade")
			
# called by GameManager when InputEvent.action_pressed("paused") == true
func pause():
	#$AnimatedSprite2D.process_mode =  Node.PROCESS_MODE_ALWAYS if $AnimatedSprite2D.process_mode==Node.PROCESS_MODE_DISABLED else Node.PROCESS_MODE_DISABLED
	self.process_mode = Node.PROCESS_MODE_ALWAYS if self.process_mode==Node.PROCESS_MODE_DISABLED else Node.PROCESS_MODE_DISABLED
