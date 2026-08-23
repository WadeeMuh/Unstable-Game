extends CharacterBody2D

var bullet_scene: PackedScene = preload("res://Allies/Sniper/sniper_bullet.tscn")
@export var fire_interval: float = 3.5
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
	bullet.pos = global_position
	bullet.rota = shoot_dir
	bullet.dir = shoot_dir
	get_tree().current_scene.add_child(bullet)
	animated_sprite.play("shoot")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "shoot":
		animated_sprite.play("idle")
