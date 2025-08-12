extends Control

func _on_start_button_pressed() -> void:
	#if Input.is_action_pressed("Primary"):
	get_tree().change_scene_to_file("res://scenes/ui/main.tscn")
