extends Node

@onready var anim := $AnimationPlayer # assigning AnimationPlayer node to a variable
@onready var turrets_container := $PanelContainer/VSplitContainer/ScrollContainer/TurretsContainer
@onready var stats_container := $PanelContainer/VSplitContainer/StatsContainer

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
