extends CharacterBody2D
var bullet_scene: PackedScene = preload("res://Allies/Sniper/sniper_bullet.tscn")
@export var fire_interval: float = 7.5
var fire_timer: float = 0.0
var current_target: Node2D = null

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0.0:
		current_target = get_nearest_zombie()
		if current_target != null:
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

func shoot(target: Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	var shoot_dir = (target.global_position - global_position).angle()
	bullet.pos = global_position
	bullet.rota = shoot_dir
	bullet.dir = shoot_dir
	get_tree().current_scene.add_child(bullet)
