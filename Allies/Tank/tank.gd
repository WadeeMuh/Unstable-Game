extends CharacterBody2D
@export var taunt_interval: float = 5.0
@onready var taunt_area: Area2D = $taunt_area
var taunt_timer: float = 5.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var taunting: bool = false
@export var chainsaw_dmg: int = 1
@export var chainsaw_range: float = 40.0
@export var chainsaw_interval: float = 1.0
var chainsaw_timer: float = 0.0

@export var player_away_penalty_time: float = 5.0
var player_away_timer: float = 0.0
var player: Node2D = null

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
	taunt_timer -= delta
	if taunt_timer <= 0.0:
		taunt_zombies()
		taunt_timer = taunt_interval
	if !taunting:
		var nearest = get_nearest_zombie()
		if nearest != null:
			var dir_index = get_dir_index(nearest.global_position - global_position)
			animated_sprite.play(str(dir_index) + "_idle")
			chainsaw_timer -= delta
			var dist = global_position.distance_to(nearest.global_position)
			if dist <= chainsaw_range and chainsaw_timer <= 0.0:
				if nearest.has_method("take_damage"):
					nearest.take_damage(chainsaw_dmg)
				chainsaw_timer = chainsaw_interval
	check_player_away(delta)
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
		global.teamwork_score += 0.5
