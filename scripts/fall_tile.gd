extends Area2D

@onready var rb: RigidBody2D = $RigidBody2D


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("player")):
		await get_tree().create_timer(0.4).timeout
		rb.set_gravity_scale(1)
