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
@onready var down_right: Marker2D = $"aim-areas/down-right"
@onready var down: Marker2D = $"aim-areas/down"
@onready var down_left: Marker2D = $"aim-areas/down-left"
@onready var up_left: Marker2D = $"aim-areas/up-left"
var aim_areas: Array = []

func player_method():
	pass

func move_anim_check():
	if moving:
		return "_run"
	else:
		return "_idle"

func _ready() -> void:
	aim_areas = [up, up_right, down_right, down, down_left, up_left]

func _physics_process(_delta: float) -> void:
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
	if closest_ang < 2 or closest_ang == 5:
		z_index = 2
	else:
		z_index = 0
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
	animated_sprite.play(str(closest_ang) + move_anim_check())
