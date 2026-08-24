extends CharacterBody2D
var bullet_scene: PackedScene = preload("res://Allies/Sniper/sniper_bullet.tscn")
@export var fire_interval: float = 3.5
@export var base_spread_degrees: float = 5.0
@export var min_spread_degrees: float = 2.0
@export var max_spread_degrees: float = 15.0
@export var score_neutral: float = 50.0
@export var score_min: float = 0.0
@export var score_max: float = 100.0
@export var no_snipe_penalty_per_sec: float = 0.2
var fire_timer: float = fire_interval
var current_target: Node2D = null
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var no_snipe_area: Area2D = $no_snipe_area

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0:
		current_target = get_nearest_zombie()
		if current_target != null and not is_in_no_snipe_area(current_target):
			shoot(current_target)
		fire_timer = fire_interval

	apply_no_snipe_penalty(delta)

	if global.teamwork_score <= 0:
		queue_free()

func apply_no_snipe_penalty(delta: float) -> void:
	var bodies = no_snipe_area.get_overlapping_bodies()
	var zombie_count = 0
	for body in bodies:
		if body.is_in_group("zombie"):
			zombie_count += 1
	if zombie_count > 0:
		global.teamwork_score -= no_snipe_penalty_per_sec * zombie_count * delta

func get_current_spread_degrees() -> float:
	var spread: float
	if global.teamwork_score >= score_neutral:
		var ratio = (global.teamwork_score - score_neutral) / (score_max - score_neutral)
		ratio = clamp(ratio, 0.0, 1.0)
		spread = lerp(base_spread_degrees, min_spread_degrees, ratio)
	else:
		var ratio = (score_neutral - global.teamwork_score) / (score_neutral - score_min)
		ratio = clamp(ratio, 0.0, 1.0)
		spread = lerp(base_spread_degrees, max_spread_degrees, ratio)
	return spread

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

func is_in_no_snipe_area(zombie: Node2D) -> bool:
	return zombie in no_snipe_area.get_overlapping_bodies()

func shoot(target: Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	var shoot_dir = (target.global_position - global_position).angle()
	var spread_rad = deg_to_rad(get_current_spread_degrees())
	shoot_dir += randf_range(-spread_rad, spread_rad)
	bullet.pos = global_position
	bullet.rota = shoot_dir
	bullet.dir = shoot_dir
	get_tree().current_scene.add_child(bullet)
	$AudioStreamPlayer2D.play()
	animated_sprite.play("shoot")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "shoot":
		animated_sprite.play("idle")
