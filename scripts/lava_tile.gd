extends Area2D

var reset: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player in lava", body)
		if (reset == false):
			reset = true
			PlayerGlobals.decrement_lives(1)
			#body.jump()
			await get_tree().create_timer(0.5).timeout
			reset = false
		if (PlayerGlobals.lives < 1):
				PlayerGlobals.mission_failed()
