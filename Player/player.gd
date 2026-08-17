extends CharacterBody2D
var can_move = true
var moving = false
var speed = 100
var dodge_speed = 225
var last_y_dir: String
var last_x_dir: String
var dodge_ang: int = 0
var dodge_velocity: Vector2 = Vector2.ZERO
var dodge_cooldown_timer: float = 0
var dodge_cooldown_duration: float = 1
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

func _on_animation_finished() -> void:
	if animated_sprite.animation.ends_with("_dodge"):
		global.dodging = false
		can_move = true
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
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

	if global.dodging:
		velocity = dodge_velocity
		move_and_slide()

	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta

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
		if moving and Input.is_action_just_pressed('dodge') and dodge_cooldown_timer <= 0:
			global.dodging = true
			can_move = false
			dodge_cooldown_timer = dodge_cooldown_duration
			dodge_velocity = velocity.normalized() * dodge_speed
			var move_dir = velocity.normalized()
			var best_ang: int = 0
			var best_dot: float = -INF
			for i in aim_areas.size():
				var marker_dir = (aim_areas[i].global_position - global_position).normalized()
				var d = move_dir.dot(marker_dir)
				if d > best_dot:
					best_dot = d
					best_ang = i
			dodge_ang = best_ang
		move_and_slide()

	if global.dodging:
		animated_sprite.play(str(dodge_ang) + "_dodge")
	else:
		animated_sprite.play(str(closest_ang) + move_anim_check())
