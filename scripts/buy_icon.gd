extends Node

# init child nodes in script
@export var buy_button: Button
@export var item_name: RichTextLabel
@export var item_cost: RichTextLabel

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
