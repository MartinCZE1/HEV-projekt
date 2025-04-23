extends Area2D
var slow_speed = 150.0
var original_speed = 300

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You entered grass")
		original_speed = body.get_speed()
		body.set_speed(slow_speed)
	

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You exited grass")
		body.set_speed(300)
