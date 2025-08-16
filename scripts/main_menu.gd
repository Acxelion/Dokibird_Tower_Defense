extends Control

@export var credits_anim: AnimationPlayer

func _ready():
	#var title_label = $CenterContainer/TitleLabel
	#title_label.set_text("[font_size=100][b][i]DOKIBIRD'S NESTICLE DEFENSE[/i][/b][/font_size]")
	pass

func _on_start_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/main.tscn")
	
	Globals.reset()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_credits_button_pressed() -> void:
	credits_anim.play("slide_in")

func _on_credits_exit_button_pressed() -> void:
	credits_anim.play_backwards("slide_in")
