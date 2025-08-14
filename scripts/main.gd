extends Node

func _ready():
	var map = load("res://scenes/maps/map1.tscn").instantiate()
	add_child(map)
	
	return
