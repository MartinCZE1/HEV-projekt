extends Control

func _ready():
	print("mission_failed scene loaded")

func _on_retry_pressed():
	print("Retry button pressed")
	if get_tree():
		await get_tree().create_timer(0.1).timeout
	await change_scene()

func _on_ragequit_pressed():
	print("Ragequit button pressed")
	if get_tree():
		get_tree().quit() 

func change_scene():
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	if get_tree():
		await get_tree().create_timer(0.1).timeout
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.reset_game()
		if game_manager.game_started:
			game_manager.emit_signal("lives_updated", game_manager.lives)
			game_manager.emit_signal("enemies_killed_updated", game_manager.enemies_killed)
