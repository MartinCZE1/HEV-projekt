extends Node2D

func _on_end_of_world_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player fell into the void. Respawning...")
		if body.is_in_group("player"):
			body.player_fell_in_void()
		else:
			printerr("Error: body is not of type Player")
