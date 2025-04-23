extends Node

var score: int = 0
var lives: int = 3
var enemies_killed: int = 0
var enemies_to_unlock_portal: int = 5 

var player_position: Vector2 = Vector2(0, 0)
var player_health: int = 100
var current_checkpoint: Vector2 = Vector2(0,0)

var game_started: bool = false


signal score_updated(score: int)
signal lives_updated(lives: int)
signal game_over
signal enemies_killed_updated(enemies_killed: int)
signal portal_unlock_updated(text: String) 
signal reset_game_signal 
signal update_player_data(position: Vector2, health: int)

func _ready():
	print("GameManager _ready() called")
	game_started = true
	
	emit_signal("score_updated", score)
	emit_signal("lives_updated", lives) 
	emit_signal("enemies_killed_updated", enemies_killed)
	emit_signal("portal_unlock_updated", "Enemies left: " + str(enemies_to_unlock_portal - enemies_killed))  
	current_checkpoint = player_position
	print("GameManager: Initial checkpoint set to:", current_checkpoint) 
	load_player_data()

func reset_game():
	score = 0
	lives = 3
	enemies_killed = 0
	enemies_to_unlock_portal = 5  
	game_started = true
	emit_signal("score_updated", score)
	emit_signal("lives_updated", lives)
	emit_signal("enemies_killed_updated", enemies_killed)
	emit_signal("portal_unlock_updated", "Enemies left: " + str(enemies_to_unlock_portal - enemies_killed)) 
	emit_signal("reset_game_signal")
	print("GameManager: reset_game() called")

func remove_life():
	print("GameManager: remove_life() function executed")
	lives -= 1
	print("GameManager: Updated lives:", lives)
	emit_signal("lives_updated", lives)

	if lives <= 0:
		score = 0
		emit_signal("score_updated", score) 

		game_started = false
		emit_signal("game_over")
		print("Game Over! Changing to mission_failed scene.")
		
		print("GameManager: Attempting to change scene to mission_failed")
		
		get_tree().change_scene_to_file("res://scenes/mission_failed.tscn")
		reset_game() 
		

func increase_enemies_killed():
	enemies_killed += 1
	emit_signal("enemies_killed_updated", enemies_killed)
	
	if enemies_killed < enemies_to_unlock_portal:
		emit_signal("portal_unlock_updated", "You need to kill " + str(enemies_to_unlock_portal - enemies_killed) + " enemies to unlock the portal")

	if enemies_killed >= enemies_to_unlock_portal:
		print("GameManager: Portal unlocked! Now the player can access it.")
		emit_signal("portal_unlock_updated", "The portal has been unlocked!")  

func add_score(points: int):
	score += points
	print("GameManager: Score updated to:", score) 
	emit_signal("score_updated", score)

func get_player_data():
	return {
		"position": player_position,
		"health": player_health
	}

func save_player_data():
	var save_data = {
		"position": player_position,
		"health": player_health,
		"checkpoint": current_checkpoint
	}
	var save_file = FileAccess.open("user://player_data.json", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("GameManager: Player data saved.")
	else:
		printerr("GameManager: Error saving player data.")

func load_player_data():
	var save_file = FileAccess.open("user://player_data.json", FileAccess.READ)
	if save_file:
		var save_data_json = save_file.get_as_text()
		save_file.close()
		var save_data = JSON.parse_string(save_data_json)
		if typeof(save_data) == TYPE_DICTIONARY:
			if save_data.position is Vector2:
				player_position = save_data.position
			else:
				printerr("GameManager: Invalid position format in save data.")
				player_position = Vector2(0,0) 
			player_health = save_data.health
			if save_data.checkpoint is Vector2:
				current_checkpoint = save_data.checkpoint
			else:
				printerr("GameManager: Invalid checkpoint format in save data.")
				current_checkpoint = Vector2(0,0)
			print("GameManager: Player data loaded. Position:", player_position, "Health:", player_health, "Checkpoint:", current_checkpoint)
		else:
			printerr("GameManager: Invalid save data format.")
	else:
		print("GameManager: No existing save data.")
