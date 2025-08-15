extends Node

@export var maximum_wave: int = 10
@onready var current_wave: int = maximum_wave

@export var starting_wealth: int = 100
@onready var wallet: int = starting_wealth

@export var max_player_health: int = 8
@onready var player_health: int = max_player_health

@onready var ui := $UI

@onready var spawner_scenes = []
var spawners = []

var paused: bool = false

func _ready():
	# instnatiate map
	var map = load("res://scenes/maps/map1.tscn").instantiate()
	add_child(map)
	
	# instantiate spawner(s)
	var enemy_route = preload("res://assets/resources/map1_route.tres")
	var spawner = load("res://scenes/enemies/spawner.tscn").instantiate()
	
	# assign attributes
	spawner.travel_path = enemy_route	# assign the route enemy spawned will take
	spawner.connect_to_spawn_signal(_on_enemy_spawned)	# call this function whenever enemy spawned
	spawner.connect_to_destroy_signal(_on_enemy_destroyed)
	spawner.connect_to_attacks_signal(_on_enemy_attacks)
	
	# add to list and game tree
	spawners.append(spawner) 
	add_child(spawner) 
	
	# update labels
	ui.update_health_bar(player_health, max_player_health)
	ui.update_currency_label(wallet)
	ui.update_wave_label(current_wave, maximum_wave)
	
	return

func _input(event):
	if event.is_action_pressed("Pause"):
		pause_game()
	
	pass

func pause_game():
	# update pause variable
	paused = not paused
	
	# call pause function of every relevant element 
	get_tree().call_group("enemy","pause")
	get_tree().call_group("turret","pause")

func _on_enemy_spawned(enemy):
	pass
	
func _on_enemy_destroyed(money_earned: int):
	pass
	
func _on_enemy_attacks(damage_taken: int):
	pass
