extends Node

# init child nodes in script
@export var buy_button: Button
@export var item_name: RichTextLabel
@export var item_cost: RichTextLabel

signal turret_purchased(cost: int)

# information regarding corresponding turret
var assigned_turret # Turret_Data object
var assigned_turret_data

# used to sore tile mouse is currently hovering over
var is_on_path: bool
var is_on_turret: bool

# constructor-like function
func assign_attributes(assigned_turret_data,):
	self.assigned_turret_data = assigned_turret_data
	self.assigned_turret = load(self.assigned_turret_data.scene)

func update_buy_icon(new_name: String, cost: int, icon: Texture2D, h_alignment: HorizontalAlignment = 0, v_alignment: VerticalAlignment = 1, expand_icon: bool = true,):
	change_item_name(new_name)
	change_item_cost(cost)
	change_buy_icon(icon, h_alignment, v_alignment, expand_icon)

func change_item_name(name: String):
	item_name.text = name
	
func change_item_cost(cost: int):
	item_cost.text = "Cost: " + str(cost)
	
func change_buy_icon(icon: Texture2D, h_alignment: HorizontalAlignment = 0, v_alignment: VerticalAlignment = 1, expand_icon: bool = true,):
	buy_button.icon = icon
	buy_button.alignment = h_alignment
	buy_button.vertical_icon_alignment = v_alignment
	buy_button.expand_icon = expand_icon	

# exposes gui_input signal to parents
func _on_buy_button_gui_input(event: InputEvent) -> void:
	if Globals.wallet >= assigned_turret_data.cost:
		_purchase_turret(event)
	else:
		if event is InputEventMouseButton and event.button_mask == 1:
			self.set("modulate", Color("ffffff48"))
		elif event is InputEventMouseButton and event.button_mask == 0:
			self.set("modulate", Color("ffffff"))

func _purchase_turret(event: InputEvent) -> void:
	# instantiate turret object
	var temp_turret = assigned_turret.instantiate()
	
	# When left-mouse down
	if event is InputEventMouseButton and event.button_mask == 1:
		temp_turret.global_position = event.global_position # assign mouse's location to turret's location
		add_child(temp_turret) # add turret to tree
		
		# adjust temp_turret's properties
		temp_turret.top_level = true # ensures it's visible
		temp_turret.process_mode = Node.PROCESS_MODE_DISABLED # prevents it from doing any actions while being dragging around
	
	# when left-mouse drag
	elif event is InputEventMouseMotion and event.button_mask == 1:
		get_child(1).global_position = event.global_position # assign mouse's location to turret's location
		get_child(1).z_index = 500 # makes sure the temp_turret is on top
		
		# check if currently hovered-over tile is not dirt
		var map_path: TileMapLayer = get_tree().get_root().get_node("GameManager/Map1/TileMapLayer") # gets tileMapLayer
		var tile: Vector2i = map_path.local_to_map(event.global_position) # translates hovering location to a coordinate on the map
		is_on_path = Vector2i(1,4) == map_path.get_cell_atlas_coords(tile) # translate map coordinate to a coordinate in tileset
		
		# checks if colliding with any other turrets
		get_child(1).process_mode = Node.PROCESS_MODE_ALWAYS
		var found_overlaps: Array[Area2D] = get_child(1).get_node("CollisionArea").get_overlapping_areas() # find all overlapping Area2Ds
		var valid_overlaps: int = found_overlaps.reduce(func (accum, ele): return accum + (1 if ele.is_in_group("collision_area") else 0), 0)
		get_child(1).process_mode = Node.PROCESS_MODE_DISABLED
		is_on_turret = ( valid_overlaps != 0 )
		
		if (is_on_path or is_on_turret): # checks if it's a dirt tile or is overlapping a turret
			get_child(1).set("modulate", Color("ffffff48")) # make red
		else:
			get_child(1).set("modulate", Color("ffffff")) # restore
		
	# when left-mouse released
	elif event is InputEventMouseButton and event.button_mask == 0:
		# removes temp_turret following mouse
		if get_child_count() > 1:
			get_child(1).queue_free()
		
		if not (is_on_path or is_on_turret): # checks if it's a dirt tile or overlapping a turret
			var path = get_tree().get_root().get_node("/root/GameManager") # gets root of scene
			path.add_child(temp_turret) # adds temp_turret to scene tree
			#print(temp_turret.name)
			#if temp_turret is AirforceDragoon:
				#temp_turret.is_flying = true
			if Globals.paused_status == true:
				temp_turret.pause()
			temp_turret.global_position = event.global_position # assigns its position to where the mouse is
			
			if temp_turret.has_signal("add_currency"):
				temp_turret.add_currency.connect(path._on_currency_added)
			
			turret_purchased.emit(assigned_turret_data.cost) # emit signal to inform successful turret purchase
			
	# catch-all, any other input could allow cancelling of purchase
	else:
		if get_child_count() > 1:
			get_child(1).queue_free()
