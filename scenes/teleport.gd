extends Area2D

@export var target_position: Vector2

func _on_area_entered(body: Node2D) -> void	:
	if body.is_in_group("player"): 
		print("Teleporting")
		body.teleport_to(-55, 111)
