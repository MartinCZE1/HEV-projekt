extends CharacterBody2D

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY = 800.0
@export var ATTACK_RANGE = 50.0
@export var attack_damage = 10
var on_ladder = false
var ladder_area: Area2D
var is_moving = false
var health = 100
var max_health = 100
var required_kills = 5
@onready var attack_area = $PlayerAttackArea
var can_attack = true
var attack_cooldown = 0.5
var attack_timer = null
var attack_timer_active = false
var teleport2_unlocked = false
@onready var portal_unlock_label = $Control/Score/PortalUnlockLabel
@onready var enemy_spawner = $EnemySpawner
@onready var health_label = $Control/Score/HealthLabel
@onready var score_label = $Control/Score/ScoreLabel
@onready var lives_label = $Control/Score/LivesLabel 

enum PlayerState {IDLE, MOVING, ATTACKING}
var current_state = PlayerState.IDLE 

var current_spawn_point: Vector2

func _ready():
	ladder_area = get_node("../LadderArea")
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	attack_area.monitoring = true
	attack_area.collision_layer = 1
	attack_area.collision_mask = 2
	if ladder_area:
		ladder_area.body_entered.connect(_on_ladder_body_entered)
		ladder_area.body_exited.connect(_on_ladder_body_exited)
	add_to_group("player")

	GameManager.connect("enemies_killed_updated", Callable(self, "_on_enemies_killed_updated"))
	GameManager.connect("reset_game_signal", Callable(self, "_on_reset_game"))
	if get_node_or_null("/root/GameManager/Score") != null:
		GameManager.connect("score_updated", get_node("/root/GameManager/Score").on_score_updated)
		GameManager.connect("lives_updated", get_node("/root/GameManager/Score").on_lives_updated)
		GameManager.connect("portal_unlock_updated", get_node("/root/GameManager/Score").on_portal_unlock_updated)  
	else:
		printerr("Score node not found.  Make sure the Score.tscn is instanced as a child of GameManager.")

	portal_unlock_label.visible = false

	update_health_label()
	update_score_label() 
	update_lives_label() 
	print("Player: _ready() called") 
	load_player_data()
	current_spawn_point = global_position

func _physics_process(delta: float) -> void:
	if not on_ladder and not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	if current_state != PlayerState.ATTACKING:
		if direction != 0:
			if not is_moving:
				$AnimatedSprite2D.play("move_right")
				$AnimatedSprite2D.flip_h = direction < 0
				$AudioStreamPlayer.play()
			is_moving = true
		else:
			if is_moving:
				$AudioStreamPlayer.stop()
			is_moving = false
			$AnimatedSprite2D.play("idle")

	if on_ladder:
		if Input.is_action_pressed("ui_down"):
			velocity.y = SPEED
		elif Input.is_action_pressed("ui_up"):
			velocity.y = -SPEED
		else:
			velocity.y = 0

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var area = collision.get_collider()
		if area is Area2D:
			if area.name == "Teleport":
				_on_teleport_body_entered(self)  
			elif area.name == "Teleport2":
				_on_teleport_2_body_entered(self) 
			elif area.name == "Teleport3":
				_on_teleport_3_body_entered(self) 
			elif area.name == "endOfWorld":
				player_fell_in_void()
			elif area.name == "endOfWorld2":
				player_fell_in_void()
			elif area.name == "endOfWorld3":
				player_fell_in_void()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and can_attack:
		perform_attack()

func perform_attack():
	current_state = PlayerState.ATTACKING 
	var animation_name = "fight" 
	$AnimatedSprite2D.play(animation_name)

	var overlapping_bodies = attack_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("Enemy"):
			body.take_damage(attack_damage)
			$FightSounds.play()

	can_attack = false
	attack_timer = get_tree().create_timer(attack_cooldown, false)
	attack_timer_active = true
	attack_timer.timeout.connect(_on_attack_cooldown_over)

	var attack_animation_length = 0.5
	var timer = get_tree().create_timer(attack_animation_length)
	timer.timeout.connect(_on_attack_animation_finished)

	var direction = Input.get_axis("ui_left", "ui_right")

	timer.timeout.connect(func() -> void:
		_on_attack_animation_finished(direction))

func _on_attack_animation_finished(dir):
	if dir != 0: 
		current_state = PlayerState.MOVING
	else:
		current_state = PlayerState.IDLE

func _on_attack_cooldown_over():
	can_attack = true
	attack_timer_active = false
	attack_timer = null

func player_take_damage(amount):
	health -= amount
	update_health_label()
	if health <= 0:
		print("Player: Player died. Respawning at:", GameManager.current_checkpoint) 
		global_position = GameManager.current_checkpoint
		health = max_health 
		update_health_label()
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")
		GameManager.player_health = health
		set_player_data()
		GameManager.save_player_data() 
		GameManager.remove_life() 
		

func _on_attack_area_body_entered(body): # Must stay! Won't work without it!
	pass

func _on_attack_area_body_exited(body):
	if body.is_in_group("Enemy") and attack_timer_active:
		attack_timer_active = false
		attack_timer = null
		can_attack = true

func _on_ladder_body_entered(body: Node2D) -> void:
	if body.is_in_group("ladders") and body == self:
		on_ladder = true

func _on_ladder_body_exited(body: Node2D) -> void:
	if body.is_in_group("ladders") and body == self:
		on_ladder = false

func _on_enemies_killed_updated(count):
	if count >= required_kills:
		teleport2_unlocked = true

func _on_teleport_body_entered(body):
	if body == self:  
		global_position = Vector2(-830, 1878)  
		current_spawn_point = global_position  
		GameManager.current_checkpoint = current_spawn_point
		print("Player: Teleported to:", global_position) 
		print("Player: Current spawn point set to:", current_spawn_point) 
		print("Player: GameManager checkpoint set to:", GameManager.current_checkpoint)
		_show_portal_unlock_label() 
		GameManager.add_score(20)
		spawn_enemies() 
		set_player_data()
		GameManager.save_player_data() 
		

func _on_teleport_2_body_entered(body: Node2D) -> void:
	if body == self:
		if teleport2_unlocked:
			global_position = Vector2(-9583, -24) 
			current_spawn_point = global_position 
			GameManager.current_checkpoint = current_spawn_point
			print("Player: Teleported to:", global_position)
			print("Player: Current spawn point set to:", current_spawn_point)
			GameManager.add_score(20)
			_hide_portal_unlock_label() 
			set_player_data()
		GameManager.save_player_data()
		

func _on_teleport_3_body_entered(body: Node2D) -> void:
	if body == self:
		global_position = Vector2(-14780, -728) 
		current_spawn_point = global_position
		GameManager.current_checkpoint = current_spawn_point
		print("Player: Teleported to:", global_position)
		print("Player: Current spawn point set to:", current_spawn_point) 
		GameManager.add_score(20)
		_hide_portal_unlock_label()
		set_player_data()
		GameManager.save_player_data()

func _show_portal_unlock_label():
	if portal_unlock_label:
		portal_unlock_label.visible = true

func _hide_portal_unlock_label():
	if portal_unlock_label:
		portal_unlock_label.visible = false

func spawn_enemies():
	if enemy_spawner:
		enemy_spawner.spawn_enemy() 

func update_health_label():
	if health_label:
		health_label.text = "Health: " + str(health) + "/" + str(max_health)

func update_score_label(): 
	if score_label:
		score_label.text = "Score: " + str(GameManager.score)

func update_lives_label(): 
	if lives_label:
		lives_label.text = "Lives: " + str(GameManager.lives)

func set_player_data():
	GameManager.player_position = global_position
	GameManager.player_health = health

func _on_reset_game():
	var data = GameManager.get_player_data()
	global_position = data.position
	health = data.health
	update_health_label()
	update_score_label() 
	update_lives_label()
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("idle")
	set_player_data()
	print("Player: _on_reset_game: position and health reset")

func load_player_data():
	var data = GameManager.get_player_data()
	if data.position != Vector2.ZERO:
		global_position = data.position
		health = data.health
		current_spawn_point = global_position
		GameManager.current_checkpoint = current_spawn_point
		update_health_label()
		update_score_label()
		update_lives_label() 
		print("Player: _load_player_data: position and health loaded")

func player_fell_in_void():
	GameManager.remove_life()
	global_position = current_spawn_point
	health = max_health 
	update_health_label()
	update_score_label()
	update_lives_label() 
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("idle")
	set_player_data()
	GameManager.save_player_data()
	print("Player: Fell in void. Respawning at checkpoint:", GameManager.current_checkpoint)
