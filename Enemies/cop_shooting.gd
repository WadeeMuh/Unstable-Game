extends CharacterBody2D

const speed: int = 50
var dir_change: int = 0
var detect_lvl: int = 0
var player: Node2D = null

@onready var gun: CharacterBody2D = $gun
@onready var gun_sprite: AnimatedSprite2D = $gun/AnimatedSprite2D
@export var gun_offset: Vector2 = Vector2(8, 4)

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var facing_left := player.global_position.x < global_position.x

	if facing_left:
		gun.position = Vector2(-gun_offset.x, gun_offset.y)
		gun_sprite.flip_v = true
	else:
		gun.position = Vector2(gun_offset.x, gun_offset.y)
		gun_sprite.flip_v = false

	gun.look_at(player.global_position)

	if detect_lvl == 2:
		velocity = (player.global_position - global_position).normalized() * -speed
	elif detect_lvl == 1:
		if dir_change > 0:
			dir_change -= 1
		else:
			var rand_dir = randi_range(0, 10)
			match rand_dir:
				0: velocity = Vector2(0, -speed)
				1: velocity = Vector2(speed, -speed).normalized() * speed
				2: velocity = Vector2(speed, 0)
				3: velocity = Vector2(speed, speed).normalized() * speed
				4: velocity = Vector2(0, speed)
				5: velocity = Vector2(-speed, speed).normalized() * speed
				6: velocity = Vector2(-speed, 0)
				7: velocity = Vector2(-speed, -speed).normalized() * speed
				_: velocity = Vector2.ZERO
			dir_change = 50
	else:
		velocity = (player.global_position - global_position).normalized() * speed

	move_and_slide()

func _on_detectionarea_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		detect_lvl += 1

func _on_detectionarea_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		detect_lvl -= 1

func _on_closedetectionarea_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		detect_lvl += 1
		$"close-detection-area/CollisionShape2D".scale = Vector2(1.5, 1.5)

func _on_closedetectionarea_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		detect_lvl -= 1
		$"close-detection-area/CollisionShape2D".scale = Vector2(1, 1)
