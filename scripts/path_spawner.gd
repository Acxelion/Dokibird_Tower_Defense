extends Node2D
### IN THE FUTURE, CHANGE TO A DIFFERENT SPAWNER PER ENEMY TYPE
### GAME MANAGER CAN SPAWN THEM AND GET THE CURVE2D FROM MAP AS AN ATTRIBUTE


# assign when instancing as a child of a map
@export var travel_path: Resource
@export var spawn_rate: int = 1 # spawns every how many seconds

@onready var spawn_timer := $SpawnTimer

# use update function before spawning enemy
@export var enemy_scene: PackedScene
signal enemy_spawned(enemy)				# signal for when enemy is spawned
var _on_enemy_destroyed: Callable		# function to attach to spawned enemy's destoryed signal
var _on_enemy_attacks: Callable			# function to attach to spawned enemy's attacks signal

@onready var num_of_enemies_to_spawn: int
@onready var enemies_spawned: int = 0
signal spawned_all_enemies


func _ready():
	spawn_timer.wait_time = spawn_rate

# changes enemy_path value, returns previous value
func change_enemy(new_enemy: PackedScene) -> PackedScene:
	var prev = enemy_scene
	enemy_scene = new_enemy
	return prev

func set_num_of_enemies_to_spawn(target: int):
	num_of_enemies_to_spawn = target

func start_spawner():
	spawn_timer.start()
	spawn_timer.set_paused(false)
	spawn_timer.timeout.emit()

#
func change_time(new_time: int):
	spawn_timer.wait_time = new_time

func connect_to_spawn_signal(foo: Callable):
	enemy_spawned.connect(foo)
	
func connect_to_destroy_signal(foo: Callable):
	_on_enemy_destroyed = foo
	
func connect_to_attacks_signal(foo: Callable):
	_on_enemy_attacks = foo

# called when timer ticks off
func _on_spawn_timer_timeout() -> void:
	# while still allowed to spawn enemies
	if enemies_spawned < num_of_enemies_to_spawn:
		# spawns an enemy
		var route = Path2D.new() 					# instantiate a new Path2D
		route.curve = travel_path					# assign it the given Curve2D resource
		
		var follow_route = PathFollow2D.new()		# instantiate a PathFollow2D
		follow_route.loop = false
		
		# assign values to the spawned enemy unit
		var enemy = enemy_scene.instantiate()		# instantiate an enemy
		enemy_spawned.emit(enemy) # signal enemy spawned and share to allow updating of values
		enemy.enemy_destroyed.connect(_on_enemy_destroyed)
		enemy.successful_enemy_attack.connect(_on_enemy_attacks)
		
		# add to game tree
		follow_route.add_child(enemy)				# add enemy as child of follow_route
		route.add_child(follow_route)				# add follow_route as child of route
		add_child(route)							# add route as a child of spawner
		
		# update counter
		enemies_spawned = enemies_spawned + 1
	else:
		spawned_all_enemies.emit()
		spawn_timer.stop()
	
# called when pause occurs
func pause():
	spawn_timer.set_paused(not spawn_timer.paused)
