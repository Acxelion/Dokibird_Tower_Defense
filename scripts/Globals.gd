###
###	CONTAINS INFORMATION THAT NEEDS TO BE MAINTAINED ACROSS SCENES
###

extends Node

@export var maximum_wave: int = 10
@onready var current_wave: int = 0

@export var starting_wealth: int = 100
@onready var wallet: int = starting_wealth

@export var max_player_health: int = 8
@onready var player_health: int = max_player_health
