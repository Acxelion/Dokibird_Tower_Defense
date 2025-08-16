###
###	CONTAINS INFORMATION THAT NEEDS TO BE MAINTAINED ACROSS SCENES
###

extends Node

var paused_status: bool = false

@export var maximum_wave: int = 10
@onready var current_wave: int = 0

@export var starting_wealth: int = 100
@onready var wallet: int = starting_wealth

@export var max_player_health: int = 8
@onready var player_health: int = max_player_health

@onready var game_finished: bool = false

@onready var difficulty: float = 0.3

func reset() -> void:
	current_wave = 0
	wallet = starting_wealth
	player_health = max_player_health
	game_finished = false
	paused_status = false
