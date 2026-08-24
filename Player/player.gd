extends CharacterBody2D
var can_move = true
var moving = false
var speed = 100
var last_y_dir: String
var last_x_dir: String
var death_animation_played: bool = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var up: Marker2D = $"aim-areas/up"
@onready var up_right: Marker2D = $"aim-areas/up-right"
@onready var right: Marker2D = $"aim-areas/right"
@onready var down_right: Marker2D = $"aim-areas/down-right"
@onready var down: Marker2D = $"aim-areas/down"
@onready var down_left: Marker2D = $"aim-areas/down-left"
@onready var left: Marker2D = $"aim-areas/left"
@onready var up_left: Marker2D = $"aim-areas/up-left"
var aim_areas: Array = []
const bullet_scene: PackedScene = preload("res://Player/player_bullet.tscn")
var fire_cooldown: float = 0.15
var fire_timer: float = 0.0
@onready var shooting_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func player_method():
	pass

func take_damage(amount: int) -> void:
	global.player_health -= amount

func move_anim_check():
	if moving:
		return "_run"
	else:
		return "_idle"

func shoot_anim_check():
	if Input.is_action_pressed("shoot"):
		return "_shoot"
	else:
		return ""

func _ready() -> void:
	aim_areas = [up, up_right, right, down_right, down, down_left, left, up_left]

func _physics_process(delta: float) -> void:
	if death_animation_played:
		return

	if global.player_health <= 0:
		can_move = false
		var dir_index = get_last_dir_index()
		animated_sprite.play(str(dir_index) + "_death")
		death_animation_played = true
		return

	var mouse_pos = get_global_mouse_position()
	var aim_dist_checked: bool = false
	var prev_dist: float
	var closest_ang: int = 0

	for angle in aim_areas:
		var distance = angle.global_position.distance_to(mouse_pos)
		if not aim_dist_checked:
			prev_dist = distance
			aim_dist_checked = true
		if distance < prev_dist:
			prev_dist = distance
			closest_ang = aim_areas.find(angle)

	z_index = int(global_position.y)

	if can_move:
		velocity = Vector2.ZERO
		if Input.is_action_pressed('move_up'):
			velocity.y = -speed
			last_y_dir = 'up'
		if Input.is_action_pressed('move_down'):
			velocity.y = speed
			last_y_dir = 'down'
		if Input.is_action_pressed('move_left'):
			velocity.x = -speed
			last_x_dir = 'left'
		if Input.is_action_pressed('move_right'):
			velocity.x = speed
			last_x_dir = 'right'
		if velocity.x != 0 and velocity.y != 0:
			velocity = velocity.normalized() * speed
		moving = velocity != Vector2.ZERO
		move_and_slide()

	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		shoot(aim_areas[closest_ang], mouse_pos)
		fire_timer = fire_cooldown

	if not Input.is_action_pressed("shoot") and shooting_sound.playing:
		shooting_sound.stop()

	animated_sprite.play(str(closest_ang) + move_anim_check() + shoot_anim_check())

@export var bullet_spread_degrees: float = 6.0
func shoot(spawn_marker: Marker2D, target_pos: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	var shoot_dir = (target_pos - spawn_marker.global_position).angle()
	var spread_rad = deg_to_rad(bullet_spread_degrees)
	shoot_dir += randf_range(-spread_rad, spread_rad)
	bullet.pos = spawn_marker.global_position
	bullet.rota = shoot_dir
	bullet.dir = shoot_dir
	get_tree().current_scene.add_child(bullet)
	shooting_sound.play()

func get_last_dir_index() -> int:
	var dir_index_map := {
		"up": {"": 0, "left": 7, "right": 1},
		"down": {"": 4, "left": 5, "right": 3},
		"": {"left": 6, "right": 2}
	}
	var y_key = last_y_dir if last_y_dir != "" else ""
	var x_key = last_x_dir if last_x_dir != "" else ""
	if dir_index_map.has(y_key) and dir_index_map[y_key].has(x_key):
		return dir_index_map[y_key][x_key]
	return 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation.ends_with("death"):
		global.dead = true
