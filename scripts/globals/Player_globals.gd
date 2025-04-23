extends Node
signal score_Changed
signal lives_Changed

var score: int = 0
var lives: int = 3

# Increment score by a certain amount
func increment_score(inc_score) -> void:
	print("Score has been incremented by: ", inc_score)
	score += inc_score
	emit_signal("score_Changed")

# Decrement lives by a certain amount
func decrement_lives(dec_lives) -> void:
	lives -= dec_lives
	emit_signal("lives_Changed")

# Handle mission failure (reset score and lives, change scene)
func mission_failed() -> void:
	get_tree().change_scene_to_file("res://scenes/mission_failed.tscn")
	score = 0
	lives = 3
	emit_signal("score_Changed")
	emit_signal("lives_Changed")
