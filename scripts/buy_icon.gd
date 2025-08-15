extends Node

# init child nodes in script
@export var buy_button: Button
@export var item_name: RichTextLabel
@export var item_cost: RichTextLabel

signal turret_purchased(cost: int)

# information regarding corresponding turret
var assigned_turret # Turret_Data object
var assigned_turret_data

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
		temp_turret.global_position = event.global_position
		
		add_child(temp_turret)
		
		temp_turret.top_level = true
		temp_turret.process_mode = Node.PROCESS_MODE_DISABLED
		temp_turret.scale = Vector2(0.25,0.25)
	
	# when left-mouse drag
	elif event is InputEventMouseMotion and event.button_mask == 1:
		get_child(1).global_position = event.global_position
		
	# when left-mouse released
	elif event is InputEventMouseButton and event.button_mask == 0:
		if get_child_count() > 1:
			get_child(1).queue_free()
		
		var path = get_tree().get_root()
		path.add_child(temp_turret)
		temp_turret.global_position = event.global_position
		temp_turret.scale = Vector2(0.25,0.25)
		
		turret_purchased.emit(assigned_turret_data.cost)
	else:
		if get_child_count() > 1:
			get_child(1).queue_free()
