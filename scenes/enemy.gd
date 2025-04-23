extends CharacterBody2D

@export var speed = 50.0
var direction = Vector2.ZERO
var gravity = 981.0
var health = 50

var can_attack = true
var attack_cooldown = 1.0
var is_moving = false

var attack_damage = 5

@onready var attack_area = $AttackArea

var attack_timer = null
var current_tree: SceneTree

func _ready():
	current_tree = get_tree()
	attack_area.monitoring = true
	attack_area.collision_layer = 1
	attack_area.collision_mask = 1
	collision_mask = collision_mask | 1

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0]
		direction = (player.global_position - global_position).normalized()
		is_moving = true
	else:
		is_moving = false
		direction = Vector2.ZERO

	if direction.length() > 0:
		direction = direction.normalized()

	velocity.x = direction.x * speed

	move_and_slide()

	if is_moving:
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("walk_right")
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("walk_right")
	else:
		$AnimatedSprite2D.play("idle")

func _process(delta):
	if is_inside_tree() and can_attack and current_tree != null:
		var overlapping_bodies = attack_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				print("Enemy attacking player")
				$AnimatedSprite2D.play("fight")

				body.player_take_damage(attack_damage)
				$EnemyFightSounds.play()

				can_attack = false
				attack_timer = Timer.new()
				attack_timer.one_shot = true
				attack_timer.wait_time = attack_cooldown
				attack_timer.timeout.connect(_on_attack_timer_timeout)
				add_child(attack_timer)
				attack_timer.start()
				break

func _on_attack_timer_timeout():
	can_attack = true
	attack_timer.queue_free()
	attack_timer = null

func take_damage(amount):
	health -= amount
	if health <= 0:
		if attack_timer != null and attack_timer.is_connected("timeout", self._on_attack_timer_timeout):
			attack_timer.queue_free()
			attack_timer = null

		current_tree = null
		call_deferred("deferred_enemy_killed")
		queue_free()

func deferred_enemy_killed():
	GameManager.add_score(10)  
	GameManager.increase_enemies_killed() 
	queue_free()
