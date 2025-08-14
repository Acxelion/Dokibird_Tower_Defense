###
###	ONLY HOLDS DICTIONARIES CONTAINING INFORMATION ABOUT ITEMS/ENEMIES
###

extends Node

const Turret_Keys = {NAME="name", COST="cost", DESC="description", ICON="icon", SCENE="scene"}

var TURRETS = {
	"regular_dragoon" = {
		"name" = "Dragoon",
		"cost" = 1,
		"description" = "asdf",
		"icon" = load("res://assets/test_turret.png"), # should be path to the scene as a string or path object
		"scene" = "", # should be path to the scene as a string or path object
	},
}
