extends Node

@onready var ui := $UI
@onready var bgm_player := $BgmPlayer

@onready var spawner_filepaths: Array[String] = ["res://scenes/enemies/spawner.tscn", ]
@onready var spawners: Array[Node] = []
@onready var enemy_routes: Array[Curve2D] = [preload("res://assets/resources/map1_route.tres"), ]
var waves: Array[Wave]

@onready var paused: bool = false
@onready var path_to_wave_quantity: String = "res://assets/wave_csv/map1/waves.txt"
@onready var path_to_wave_delay: String = "res://assets/wave_csv/map1/delay.txt"

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
	Globals.maximum_wave = len(waves)
	
	# update labels
	ui.update_health_bar(Globals.player_health, Globals.max_player_health)
	ui.update_currency_label(Globals.wallet)
	ui.update_wave_label(Globals.current_wave+1, Globals.maximum_wave)
	ui.toggle_button_response = pause_game
	
	# start music
	bgm_player.play()
	
	# prepare first wave
	wave_timer.timeout.connect(waves[0]._update_delays)
	waves[0].prepare_wave()
	#wave_timer.start()
	
	# pause game
	ui.play_button.set_pressed(paused)

func _input(event):
	if (not Globals.game_finished) and event.is_action_pressed("Pause"):
		# pause_game()
		ui.play_button.set_pressed(paused) # can call this over pause_game() b/c signal wil call pause_game()
	
	pass

func on_turret_purchase(cost: int):
	self.wallet = self.wallet - cost
	ui.update_currency_label(self.wallet)

func pause_game():
	# update pause variable
	paused = not paused
	
	# call pause function of every relevant element 
	get_tree().call_group("enemy","pause")
	get_tree().call_group("turret","pause")
	get_tree().call_group("wave_timers","set_paused", paused)
	
func game_win():
	# print("GAME VICTORY")
	ui.reveal_game_state_panel("[font_size=75][b][i]GAME VICTORY[/i][/b][/font_size]")
	
	Globals.game_finished = true
	
func game_over():
	# print("GAME OVER")
	ui.reveal_game_state_panel("[font_size=75][b][i]GAME OVER[/i][/b][/font_size]")
	
	ui.play_button.set_pressed(paused) # can call this over pause_game() b/c signal wil call pause_game()
	
	Globals.game_finished = true

# called when a wave is completed
func wave_finished():
	print("WAVE FINISHED")
	
	# setup next wave
	wave_timer.disconnect("timeout", waves[Globals.current_wave]._update_delays)
	Globals.current_wave = Globals.current_wave + 1
	if Globals.current_wave >= Globals.maximum_wave:
		game_win()
	else:
		ui.update_wave_label(Globals.current_wave+1, Globals.maximum_wave)
		wave_timer.timeout.connect(waves[Globals.current_wave]._update_delays)
		waves[Globals.current_wave].prepare_wave()
		
		# pause game
		ui.play_button.set_pressed(paused)

func _on_enemy_spawned(enemy):
	pass
	
func _on_enemy_destroyed(money_earned: int):
	# gives money to player equal to destroyed enemy's worth
	Globals.wallet = Globals.wallet + money_earned
	ui.update_currency_label(Globals.wallet)
	
	# updates tracker of wave's remaining enemies
	waves[Globals.current_wave].enemies_remaining = waves[Globals.current_wave].enemies_remaining - 1
	if waves[Globals.current_wave].enemies_remaining <= 0: # calls wave_finished() if no more enemies remain
		wave_finished()
	
func _on_enemy_attacks(damage_taken: int):
	# updates player's health and corresponding label
	Globals.player_health = Globals.player_health - damage_taken
	ui.update_health_bar(Globals.player_health, Globals.max_player_health)
	
	# calls game over function if player's health hits zero
	if Globals.player_health == 0:
		game_over()
	
	# updates tracker of wave's remaining enemies
	waves[Globals.current_wave].enemies_remaining = waves[Globals.current_wave].enemies_remaining - 1
	if waves[Globals.current_wave].enemies_remaining <= 0: # calls wave_finished() if no more enemies remain
		wave_finished()

func _on_spawner_finished():
	print("A SPAWNER FINISHED")
	pass
