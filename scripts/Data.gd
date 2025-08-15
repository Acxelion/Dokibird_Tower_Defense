###
###	ONLY HOLDS DICTIONARIES & CONSTS CONTAINING INFORMATION ABOUT ITEMS/ENEMIES
###

extends Node

# rather than an HP bar, health will be indicated by how much the string has changed
const FULL_HP = "DRAGOONS"
const ZERO_HP = "NESTICLE"


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
