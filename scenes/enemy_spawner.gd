extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var spawn_interval: float = 3.0
@export var spawn_x_min: int = -160
@export var spawn_x_max: int = 200
@export var spawn_y: int = 90
@export var max_spawns: int = 5 

var spawn_count = 0

func _ready():
	if (spawn_count != 5):
		spawn_enemy()
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy():
	if spawn_count < max_spawns:
		var enemy = enemy_scene.instantiate()
		var random_x = randf_range(spawn_x_min, spawn_x_max)
		enemy.position = Vector2(random_x, spawn_y)
		add_child(enemy)
		spawn_count += 1
