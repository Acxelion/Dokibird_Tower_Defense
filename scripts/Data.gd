###
###	ONLY HOLDS DICTIONARIES & CONSTS CONTAINING INFORMATION ABOUT ITEMS/ENEMIES
###

extends Node

var dokibird_grunt_sfx: AudioStream = preload("res://assets/sfx/dokibird_grunt.wav")

# rather than an HP bar, health will be indicated by how much the string has changed
const FULL_HP = "DRAGOONS"
const ZERO_HP = "NESTICLE"

# Inner class for maintaining turrets
class Turret_Data:
	var turret_name: String 	# Name displayed in shop for turret
	var cost: int				# How much money the turret will cost
	var description: String		# A short description of the turret
	var icon: Resource			# Loaded sprite/png of the turret to be used for shop icon
	var scene: String			# Filepath to scene for the turret in order to later instantiate it
	
	func _init(turret_name, cost, description, icon, scene):
		self.turret_name = turret_name
		self.cost = cost
		self.description = description
		self.icon = icon
		self.scene = scene

# list containing all the turrets' information as Turret_Data objects
@onready var TURRETS = {
	#"regular_dragoon" = Turret_Data.new("Dragoon", 1, "asdf", load("res://assets/test_turret.png"), ""),

	"egg_prod" = Turret_Data.new("Egg Producer", 1, "Dokium is eggs", load("res://assets/dragoons/egg-prod/01.png"), "res://scenes/dragoons/dokiumProd/eggProd/egg_prod.tscn"),
	"tomato_goon" = Turret_Data.new("Tomatogoon", 1, "Tomato Potato", load("res://assets/dragoons/tomato-goon/idle1.png"), "res://scenes/dragoons/regularDragoon/tomatoGoon/tomato_goon.tscn"),
	"airforce_goon" = Turret_Data.new("Tomatogoon", 1, "Airforce Dragoon", load("res://assets/dragoons/airforce-dragoons/a1.png"), "res://scenes/dragoons/regularDragoon/airforceDragoon/airforce_dragoon.tscn"),
}
