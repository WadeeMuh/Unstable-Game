extends CharacterBody2D
const speed: int = 50
var player: Node2D = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	velocity = (player.global_position - global_position).normalized() * speed
	move_and_slide()

	var dir_index = get_dir_index(velocity)
	animated_sprite.play(str(dir_index) + "_run" + "_Z" + str(7))

func get_dir_index(dir: Vector2) -> int:
	if dir == Vector2.ZERO:
		return 0
	var angle_deg = rad_to_deg(dir.angle()) + 90.0
	if angle_deg < 0:
		angle_deg += 360.0
	return int(round(angle_deg / 45.0)) % 8
