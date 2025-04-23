extends Control

class_name Score  

@onready var score_label: Label = $Label
@onready var hearts1: TextureRect = $HFlowContainer/hearts
@onready var hearts2: TextureRect = $HFlowContainer/hearts2
@onready var hearts3: TextureRect = $HFlowContainer/hearts3
@onready var portal_unlock_label: Label = $PortalUnlockLabel  
var game_manager

func _ready():
	game_manager = get_node("/root/GameManager")  
	game_manager.score_updated.connect(on_score_updated)
	game_manager.lives_updated.connect(on_lives_updated)
	game_manager.enemies_killed_updated.connect(on_enemies_killed_updated)
	game_manager.portal_unlock_updated.connect(on_portal_unlock_updated)  
	game_manager.game_over.connect(on_game_over) 
	on_score_updated(game_manager.score)
	on_lives_updated(game_manager.lives)

func on_score_updated(score):
	score_label.text = "Score: " + str(score)

func on_lives_updated(lives):
	print("Updating hearts in UI with lives:", lives)
	if game_manager != null:
		hearts1.visible = lives >= 3
		hearts2.visible = lives >= 2
		hearts3.visible = lives >= 1
	else:
		print("Error: GameManager is null in on_lives_updated")

func on_enemies_killed_updated(count):
	print("Enemies killed:", count)

func on_portal_unlock_updated(text):
	portal_unlock_label.text = text  

func on_game_over():
	hearts1.visible = true
	hearts2.visible = true
	hearts3.visible = true
