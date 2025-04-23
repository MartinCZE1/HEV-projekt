extends Area2D
var big_jump = -300

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You entered jump tile")
		body.set_jump(-300)
	

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You exited jump tile")
		body.set_jump(-600)
