extends AnimatableBody2D

func _ready() -> void:
	$AnimationPlayer.play("move")

func _on_timer_timeout() -> void:
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("move")
