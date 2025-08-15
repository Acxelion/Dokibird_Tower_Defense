extends Node

@export var maximum_wave: int = 10
@onready var current_wave: int = 0

@export var starting_wealth: int = 100
@onready var wallet: int = starting_wealth

@export var max_player_health: int = 8
@onready var player_health: int = max_player_health

@onready var ui := $UI
@onready var bgm_player := $BgmPlayer

@onready var spawner_filepaths: Array[String] = ["res://scenes/enemies/spawner.tscn", ]
@onready var spawners: Array[Node] = []
@onready var enemy_routes: Array[Curve2D] = [preload("res://assets/resources/map1_route.tres"), ]
var waves: Array[Wave]

@onready var paused: bool = false
@onready var path_to_wave_quantity: String = "res://assets/wave_csv/map1/waves.csv"
@onready var path_to_wave_delay: String = "res://assets/wave_csv/map1/delay.csv"

@onready var wave_timer := $WaveTimer
var num_spawners_finished: int = 0

class Wave:
	# both arrays should have the same length as spawners
	var quantity: Array = [] # number of enemies ith spawner will create this wave
	var delay: Array = [] # how long to wait before the ith spawner creates enemies this wave
	var spawners: Array # NOTE: Gdscript passes arrays by reference, not copy/value
	var enemies_remaining: int = 0
	
	# intialize variables
	func _init(new_quantity: Array, delay_secs: Array, spawners: Array):
		quantity = new_quantity
		delay = delay_secs
		self.spawners = spawners
		enemies_remaining = quantity.reduce((func (x,y): return x+y), 0) # sum function
		
	# sets up spawners for wave ot begin
	# NOTE: don't need to start the spawners, will be started by _update_delays()
	func prepare_wave():
		# tell each spawner how many enemies it will spawn this wave
		for idx in range(len(quantity)):
			spawners[idx].set_num_of_enemies_to_spawn(quantity[idx])
			spawners[idx].enemies_spawned = 0
		
	# called every second by wave_timer to lower all elements in delay by one
	# if any element in delay hits ZERO, starts corresponding spawner
	func _update_delays():
		for i in range(len(delay)):
			if delay[i] == 0:
				spawners[i].start_spawner()
			delay[i] = delay[i] - 1
		print("WaveTimer one tick %s" % [str(delay[0]),])

# given a pair of paths to CSV files, populates waves with a list of Wave objects
func instantiate_waves(quantity_path: String, delay_path: String, spawners: Array):
	# open files
	var quantity_file = FileAccess.open(quantity_path, FileAccess.READ) # open the quantity file
	var delay_file = FileAccess.open(delay_path, FileAccess.READ) # open delay file

	# translate each row to an appropriate wave object
	while not quantity_file.eof_reached():	# can do both files since they should have the same number of rows
		# get next line in file
		var quantity_csv_row: Array = quantity_file.get_csv_line() # delimiter is "," by default
		var delay_csv_row: Array = delay_file.get_csv_line()
		
		# convert csv files to an array of integers
		var q_arr: Array = quantity_csv_row.map(func(element): return int(element))
		var d_arr: Array = delay_csv_row.map(func(element): return int(element))
		
		waves.append(Wave.new(q_arr, d_arr, spawners))
	
	quantity_file.close() # close the quantity file
	delay_file.close() # close the delay file
		
func _ready():
	# instantiate map
	var map = load("res://scenes/maps/map1.tscn").instantiate()
	add_child(map)
	
	# instantiate spawner(s)
	for idx in range(len(spawner_filepaths)):
		spawners.append(load(spawner_filepaths[idx]).instantiate()) 	# instantiate spawner
		spawners[-1].travel_path = enemy_routes[idx]					# assign path spawned enemies will take
		# spawners[-1].pause()											# make sure the spawner is paused
		
		# connecting signals
		spawners[-1].connect_to_spawn_signal(_on_enemy_spawned)	# call this function whenever enemy spawned
		spawners[-1].connect_to_destroy_signal(_on_enemy_destroyed)
		spawners[-1].connect_to_attacks_signal(_on_enemy_attacks)
		spawners[-1].spawned_all_enemies.connect(_on_spawner_finished)
		
		# add to game tree
		add_child(spawners[-1]) 
	
	# instantiate waves
	instantiate_waves(path_to_wave_quantity, path_to_wave_delay, spawners)
	waves.resize(len(waves)-1)
	maximum_wave = len(waves)
	
	# update labels
	ui.update_health_bar(player_health, max_player_health)
	ui.update_currency_label(wallet)
	ui.update_wave_label(current_wave+1, maximum_wave)
	ui.toggle_button_response = pause_game
	
	# start music
	bgm_player.play()
	
	# start first wave
	wave_timer.timeout.connect(waves[0]._update_delays)
	waves[0].prepare_wave()
	wave_timer.start()
	
	
	return

func _input(event):
	if event.is_action_pressed("Pause"):
		# pause_game()
		ui.play_button.set_pressed(paused) # can call this over pause_game() b/c signal wil call pause_game()
	
	pass

func pause_game():
	# update pause variable
	paused = not paused
	
	# call pause function of every relevant element 
	get_tree().call_group("enemy","pause")
	get_tree().call_group("turret","pause")
	get_tree().call_group("wave_timers","set_paused", paused)
	
func game_win():
	print("GAME VICTORY")
	
func game_over():
	print("GAME OVER")

# called when a wave is completed
func wave_finished():
	print("WAVE FINISHED")
	
	# setup next wave
	wave_timer.disconnect("timeout", waves[current_wave]._update_delays)
	current_wave = current_wave + 1
	if current_wave >= maximum_wave:
		game_win()
	else:
		ui.update_wave_label(current_wave+1, maximum_wave)
		wave_timer.timeout.connect(waves[current_wave]._update_delays)
		waves[current_wave].prepare_wave()
		
		# pause game
		ui.play_button.set_pressed(paused)

func _on_enemy_spawned(enemy):
	pass
	
func _on_enemy_destroyed(money_earned: int):
	# gives money to player equal to destroyed enemy's worth
	wallet = wallet + money_earned
	ui.update_currency_label(wallet)
	
	# updates tracker of wave's remaining enemies
	waves[current_wave].enemies_remaining = waves[current_wave].enemies_remaining - 1
	if waves[current_wave].enemies_remaining <= 0: # calls wave_finished() if no more enemies remain
		wave_finished()
	
func _on_enemy_attacks(damage_taken: int):
	# updates player's health and corresponding label
	player_health = player_health - damage_taken
	ui.update_health_bar(player_health, max_player_health)
	
	# calls game over function if player's health hits zero
	if player_health == 0:
		game_over()
	
	# updates tracker of wave's remaining enemies
	waves[current_wave].enemies_remaining = waves[current_wave].enemies_remaining - 1
	if waves[current_wave].enemies_remaining <= 0: # calls wave_finished() if no more enemies remain
		wave_finished()

func _on_spawner_finished():
	print("A SPAWNER FINISHED")
	pass
