extends Node

@onready var sfx_players: Array[AudioStreamPlayer] = []

# Spawns an AudioStreamPlayer to play passed SFX
# On AudioStreamPlayer's finished signal, frees said AudioStreamPlayer
func play_sfx(sfx: AudioStream): # -> AudioStreamPlayer:
	sfx_players.append(AudioStreamPlayer.new())
	sfx_players[-1].stream = sfx
	sfx_players[-1].finished.connect(_clean_up_player.bind(sfx_players[-1]))
	add_child(sfx_players[-1])
	sfx_players[-1].play()

func _clean_up_player(player: AudioStreamPlayer):
	player.queue_free()
