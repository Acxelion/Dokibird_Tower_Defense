extends CharacterBody2D

@export var base_speed: int = 1000
@export var base_health: int = 1
@export var base_damage: int = 1
@export var value: int = 1

@onready var parent = get_parent()
@onready var anim = $AnimationPlayer
@onready var death_sounds: Array[AudioStream] = [preload("res://assets/resources/grunt_1.tres"),]

var speed: int = base_speed
var health: int = base_health
var damage: int = base_damage

# Signals
signal successful_enemy_attack(damage: int)				# indicates enemy reached the end of path
signal enemy_destroyed(money_earned: int)				# indicates this enemy was destroyed/HP reached zero

var paused: bool = false

func _process(delta):
	if not paused:
		parent.progress = (parent.progress + speed * delta)
		if parent.progress_ratio >= 1.0: # if it finished the path
			finished_route()
	else:
		pass
		
func finished_route():
	# if it survived the whole path, signal to game manager that the player has taken damage
	if health > 0:
		successful_enemy_attack.emit(damage)
	
	# clean up tree
	parent.get_parent().queue_free() # erase it and its forefathers
		
# called to lower health by damage_taken
# returns True if enemy was destroyed
# should be called by attacking object
func get_damage(damage_taken: int) -> bool:
	# update HP
	health -= damage_taken
	
	if health <= 0:
		# emit signal for game manager that enemy was destroyed
		enemy_destroyed.emit(value)
		
		# play death track
		SfxManager.play_sfx(death_sounds.pick_random())
		
		# remove this unit and its forefathers
		parent.get_parent().queue_free()
		
		# return survival status
		return true
	else:
		
		# return survival status
		return false

# called whenever player inputs a pause command
func pause():
	paused = not paused
	if paused:
		anim.pause()
	else:
		anim.play()
