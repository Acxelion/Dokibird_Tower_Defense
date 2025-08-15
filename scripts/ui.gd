extends Node

@onready var anim := $AnimationPlayer # assigning AnimationPlayer node to a variable
@onready var turrets_container := $PanelContainer/VSplitContainer/ScrollContainer/TurretsContainer
@onready var health_label := $PanelContainer/VSplitContainer/StatsContainer/HealthLabel
@onready var currency_label := $PanelContainer/VSplitContainer/StatsContainer/CurrencyLabel
@onready var wave_label := $PanelContainer/VSplitContainer/StatsContainer/WaveLabel

@onready var buy_icon_path = "res://scenes/ui/buy_icon.tscn"

func _ready():
	# populating TurretsContainer with turrets defined in Data.gd
	for key in Data.TURRETS.keys(): # name, cost, description, icon, scene
		
		# load and instantiate buy_icon scene
		var turret_scene = load(buy_icon_path)
		var turret_purchase_icon = turret_scene.instantiate()
		
		# add scene into turrets_container as a child
		turrets_container.add_child(turret_purchase_icon)
		
		# assign values to turret_purchase_icon
		var curr_turret = Data.TURRETS[key]
		turret_purchase_icon.update_buy_icon(curr_turret["name"], curr_turret["cost"], curr_turret["icon"])
	
	return
	
# When MenuButton is clicked, plays one of two animations
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on: # menu opened
		anim.play("open_menu")
	else: # menu closed
		anim.play("close_menu")
		
# updates health_label's text given player's current and maximum HP
func update_health_bar(new_hp: int, max_hp: int):
	health_label.text = Data.FULL_HP.substr(0, new_hp) + Data.ZERO_HP.substr(new_hp, max_hp)

# updates currency label to "Dokium: {new_value}"
func update_currency_label(new_value: int):
	currency_label.text = "Dokium: " + str(new_value)

# updates wave_label to "{wave_num} / {maximum_wave}"
func update_wave_label(wave_num: int, maximum_wave: int):
	wave_label.text = "Wave: " + str(wave_num) + " / " + str(maximum_wave)
