extends AnimatableBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("move")


func _on_timer_timeout() -> void:
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("move")