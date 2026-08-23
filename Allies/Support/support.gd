extends CharacterBody2D
var heal_zone_scene: PackedScene = preload("res://Allies/Support/healing_zone.tscn")
@export var spawn_interval: float = 10.0
var spawn_timer: float = 0.0
@export var spawn_min: Vector2 = Vector2(-128, -64)
@export var spawn_max: Vector2 = Vector2(128, 64)

var bullet_scene: PackedScene = preload("res://Allies/Support/support_bullet.tscn")
@export var fire_interval: float = 3.0
var fire_timer: float = 0.0
var current_target: Node2D = null

func _physics_process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_heal_zone()
		spawn_timer = spawn_interval

	fire_timer -= delta
	if fire_timer <= 0.0:
		current_target = get_nearest_zombie()
		if current_target != null:
			shoot(current_target)
		fire_timer = fire_interval

func spawn_heal_zone() -> void:
	var heal_zone = heal_zone_scene.instantiate()
	var spawn_pos = Vector2(
		randf_range(spawn_min.x, spawn_max.x),
		randf_range(spawn_min.y, spawn_max.y)
	)
	heal_zone.global_position = spawn_pos
	get_tree().current_scene.add_child(heal_zone)

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

func shoot(target: Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	var shoot_dir = (target.global_position - global_position).angle()
	bullet.pos = global_position
	bullet.rota = shoot_dir
	bullet.dir = shoot_dir
	get_tree().current_scene.add_child(bullet)
