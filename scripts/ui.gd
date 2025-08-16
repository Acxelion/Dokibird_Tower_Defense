extends Node

@onready var anim := $AnimationPlayer # assigning AnimationPlayer node to a variable
@onready var play_button := $PlayButton
@onready var turrets_container := $Control/SidePanel/VSplitContainer/ScrollContainer/TurretsContainer
@onready var health_label := $Control/SidePanel/VSplitContainer/StatsContainer/HealthLabel
@onready var currency_label := $Control/SidePanel/VSplitContainer/StatsContainer/CurrencyLabel
@onready var wave_label := $Control/SidePanel/VSplitContainer/StatsContainer/WaveLabel
@onready var game_state_panel := $GameStatePanel
@onready var game_state_label := $GameStatePanel/MarginContainer/GameStateLabel

@onready var buy_icon_path = "res://scenes/ui/buy_icon.tscn"

@onready var panel_revealed: bool = false

var toggle_button_response: Callable

func _ready():
	# populating TurretsContainer with turrets defined in Data.gd
	for key in Data.TURRETS.keys(): # name, cost, description, icon, scene
		# current turret
		var current_item = Data.TURRETS[key]
		
		# load and instantiate buy_icon scene
		var buy_turret_scene = load(buy_icon_path)
		var buy_turret_btn = buy_turret_scene.instantiate()
		
		# add scene into turrets_container as a child
		turrets_container.add_child(buy_turret_btn)
		
		# assign values to buy_turret_btn
		buy_turret_btn.update_buy_icon(current_item.turret_name, current_item.cost, current_item.icon)
		buy_turret_btn.assign_attributes(current_item)
		buy_turret_btn.turret_purchased.connect(_on_turret_purchase)
	
	return

func _on_turret_purchase(cost: int):
	Globals.wallet = Globals.wallet - cost
	update_currency_label(Globals.wallet)

# When MenuButton is clicked, plays one of two animations
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on: # menu opened
		anim.play("open_menu")
	else: # menu closed
		anim.play("close_menu")

#
func _on_play_button_toggled(toggled_on: bool):
	toggle_button_response.call()

# updates health_label's text given player's current and maximum HP
func update_health_bar(new_hp: int, max_hp: int):
	health_label.text = Data.FULL_HP.substr(0, new_hp) + Data.ZERO_HP.substr(new_hp, max_hp)

# updates currency label to "Dokium: {new_value}"
func update_currency_label(new_value: int):
	currency_label.text = "Dokium: " + str(new_value)

# flips game_state_panel's state
# assigns text to game_state_label
# returns panel's current state(has_slide_in or has_slide_out)
func reveal_game_state_panel(text: String) -> bool:
	if panel_revealed:
		anim.play_backwards("slide_in_game_state_panel")
	else:
		anim.play("slide_in_game_state_panel")
		
	game_state_label.text = text
		
	return panel_revealed

# updates wave_label to "{wave_num} / {maximum_wave}"
func update_wave_label(wave_num: int, maximum_wave: int):
	wave_label.text = "Wave: " + str(wave_num) + " / " + str(maximum_wave)

func _on_restart_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/menus/main_menu.tscn")
	Globals.game_finished = false

func _on_quit_button_pressed() -> void:
	get_tree().quit()
