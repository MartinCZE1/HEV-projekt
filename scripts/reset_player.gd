extends Node2D

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = GameManager.player_position
		player.health = GameManager.player_health
		player.show()
	else:
		print("Player not found in group 'player'!")
