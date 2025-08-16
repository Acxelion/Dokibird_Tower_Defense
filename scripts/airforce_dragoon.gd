class_name AirforceDragoon
extends Node2D

@export var speed = 200.0
@export var left_bound = 0.0 # The X-coordinate where the plane turns around on the left
@export var right_bound = 1100.0 # The X-coordinate where the plane turns around on the right
@export var fly_y = 100.0 # The constant Y-coordinate for the plane to fly at

@onready var animated_sprite = $AnimatedSprite2D
@onready var map = get_tree().get_root().get_node("GameManager/Map1/TileMap")
@onready var timer = $Timer

var direction = 1 # 1 for right, -1 for left
var is_flying = false
var explosion_scene = preload("res://scenes/dragoons/regularDragoon/airforceDragoon/explosion.tscn")

var path_tiles = [
	Vector2i(1, 4), 
	Vector2i(2, 5),
	Vector2i(3, 6),
]

func _ready():
	global_position = Vector2(left_bound, fly_y)
	animated_sprite.play("idle")
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _physics_process(delta):
	if is_flying:
		# Manually update the position instead of using velocity and move_and_slide()
		position.x += speed * direction * delta
	
		# Check for boundaries and flip the sprite.
		if global_position.x >= right_bound and direction == 1:
			direction = -1
			animated_sprite.flip_v = true
		elif global_position.x <= left_bound and direction == -1:
			direction = 1
			animated_sprite.flip_v = false


func _on_timer_timeout() -> void:
	var map_path: TileMapLayer = get_tree().get_root().get_node("GameManager/Map1/TileMapLayer") # gets tileMapLayer
	var tile: Vector2i = map_path.local_to_map(global_position) # translates hovering location to a coordinate on the map
	var is_on_path = Vector2i(1,4) == map_path.get_cell_atlas_coords(tile) # translate map coordinate to a coordinate in tileset

	if is_on_path:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
