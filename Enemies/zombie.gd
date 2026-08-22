extends CharacterBody2D
const speed: int = 50
var player: Node2D = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var attack_dirs: Array = [false, false, false, false, false, false, false, false]

var death_anim_played = false

var zombie_num: int
var health: int = 5

func _ready() -> void:
	zombie_num = randi_range(1, 8)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if !death_anim_played:
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()
		var dir_index = get_dir_index(player.global_position - global_position)
		animated_sprite.play(str(dir_index) + "_run" + "_Z" + str(zombie_num))
		if health <= 0:
			animated_sprite.play(str(dir_index) + "_death" + "_Z" + str(zombie_num))
			$CollisionShape2D.queue_free()
			death_anim_played = true
			await animated_sprite.animation_finished
			queue_free()

	z_index = int(global_position.y)
	

func get_dir_index(dir: Vector2) -> int:
	if dir == Vector2.ZERO:
		return 0
	var angle_deg = rad_to_deg(dir.angle()) + 90.0
	if angle_deg < 0:
		angle_deg += 360.0
	return int(round(angle_deg / 45.0)) % 8

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("bullet_method"):
		health -= 1


func _on_0_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[0] = true

func _on_1_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[1] = true

func _on_2_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[2] = true

func _on_3_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[3] = true

func _on_4_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[4] = true

func _on_5_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[5] = true

func _on_6_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[6] = true

func _on_7_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[7] = true


func _on_0_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[0] = false

func _on_1_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[1] = false

func _on_2_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[2] = false

func _on_3_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[3] = false

func _on_4_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[4] = false

func _on_5_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[5] = false

func _on_6_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[6] = false

func _on_7_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("player_method"):
		attack_dirs[7] = false
