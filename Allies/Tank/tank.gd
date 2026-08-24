extends CharacterBody2D

@export var taunt_interval: float = 5.0
@onready var taunt_area: Area2D = $taunt_area
@onready var taunt_area_shape: CollisionShape2D = $taunt_area/CollisionShape2D
var taunt_timer: float = 5.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var taunting: bool = false

@export var chainsaw_range: float = 40.0

@export var player_away_penalty_time: float = 5.0
var player_away_timer: float = 0.0
var player: Node2D = null

@export var base_taunt_radius: float = 50.0
@export var min_taunt_radius: float = 20.0
@export var max_taunt_radius: float = 90.0
@export var score_neutral: float = 50.0
@export var score_min: float = 0.0
@export var score_max: float = 100.0

func player_method():
	pass
	
func take_damage(_amount: int) -> void:
	pass
	
func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	taunt_area.body_entered.connect(_on_taunt_area_body_entered)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)
	update_taunt_area_size()
	taunt_timer -= delta
	if taunt_timer <= 0.0:
		taunt_zombies()
		taunt_timer = taunt_interval
	if !taunting:
		var nearest = get_nearest_zombie()
		if nearest != null:
			var dir_index = get_dir_index(nearest.global_position - global_position)
			animated_sprite.play(str(dir_index) + "_idle")
			var dist = global_position.distance_to(nearest.global_position)
			if dist <= chainsaw_range:
				if nearest.has_method("take_damage"):
					nearest.take_damage(9999)
	check_player_away(delta)
	
	if global.teamwork_score <= 0:
		queue_free()
	
func update_taunt_area_size() -> void:
	var radius: float
	if global.teamwork_score >= score_neutral:
		var ratio = (global.teamwork_score - score_neutral) / (score_max - score_neutral)
		ratio = clamp(ratio, 0.0, 1.0)
		radius = lerp(base_taunt_radius, max_taunt_radius, ratio)
	else:
		var ratio = (score_neutral - global.teamwork_score) / (score_neutral - score_min)
		ratio = clamp(ratio, 0.0, 1.0)
		radius = lerp(base_taunt_radius, min_taunt_radius, ratio)
	if taunt_area_shape.shape is CircleShape2D:
		taunt_area_shape.shape.radius = radius
		
func check_player_away(delta: float) -> void:
	if player == null:
		return
	if player in taunt_area.get_overlapping_bodies():
		player_away_timer = 0.0
	else:
		player_away_timer += delta
		if player_away_timer >= player_away_penalty_time:
			global.teamwork_score -= 3
			player_away_timer = 0.0
			
func get_nearest_zombie() -> Node2D:
	var zombies = get_tree().get_nodes_in_group("zombie")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for zombie in zombies:
		var dist = global_position.distance_to(zombie.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = zombie
	return nearest
	
func get_dir_index(dir: Vector2) -> int:
	if dir == Vector2.ZERO:
		return 0
	var angle_deg = rad_to_deg(dir.angle()) + 90.0
	if angle_deg < 0:
		angle_deg += 360.0
	return int(round(angle_deg / 45.0)) % 8
	
func taunt_zombies() -> void:
	taunting = true
	animated_sprite.play("taunt")
	var bodies = taunt_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("zombie"):
			body.player = self
			
func _on_animation_finished() -> void:
	if taunting and animated_sprite.animation == "taunt":
		taunting = false
		
func _on_taunt_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("zombie") and body.has_signal("died"):
		if not body.died.is_connected(_on_tracked_zombie_died):
			body.died.connect(_on_tracked_zombie_died)
			
func _on_tracked_zombie_died(zombie: Node2D) -> void:
	if zombie in taunt_area.get_overlapping_bodies():
		global.teamwork_score += 1
