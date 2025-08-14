extends Node2D

# assign when instancing as a child of a map
@export var travel_path: Resource
@export var spawn_rate: int = 1

@onready var spawn_timer := $SpawnTimer

# use update function before spawning enemy
@export var enemy_path: PackedScene
var enemy_attributes = {
	"health": 1,
	"speed": 100,
}

func _ready():
	spawn_timer.wait_time = spawn_rate

# changes enemy_path value, returns previous value
func change_enemy(new_enemy: PackedScene) -> PackedScene:
	var prev = enemy_path
	enemy_path = new_enemy
	return prev
	
func change_time(new_time: int):
	spawn_timer.wait_time = new_time

func update_enemy_attributes(health: int, speed: int):
	enemy_attributes["health"] = health
	enemy_attributes["speed"] = speed

# called when timer ticks off
func _on_spawn_timer_timeout() -> void:
	# spawns an enemy
	var route = Path2D.new() 					# instantiate a new Path2D
	route.curve = travel_path					# assign it the given Curve2D resource
	
	var follow_route = PathFollow2D.new()		# instantiate a PathFollow2D
	follow_route.loop = false
	
	# assign values to the spawned enemy unit
	var enemy = enemy_path.instantiate()		# instantiate an enemy
	enemy.health = enemy_attributes["health"] # needs safety check
	enemy.speed = enemy_attributes["speed"]
	
	follow_route.add_child(enemy)				# add enemy as child of follow_route
	route.add_child(follow_route)				# add follow_route as child of route
	add_child(route)							# add route as a child of spawner
