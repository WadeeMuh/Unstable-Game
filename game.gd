extends Node2D
@onready var player: CharacterBody2D = $Player
@onready var zombie_spawn: Area2D = $zombie_spawn
@onready var zombie_spawn_shapes: Array[CollisionShape2D] = []
const zombie_scene: PackedScene = preload("res://Enemies/zombie.tscn")
@export var base_spawn_interval: float = 4.0
@export var min_spawn_interval: float = 0.75
@export var kills_for_min_interval: float = 100.0
@export var base_spawn_count: int = 1
@export var max_spawn_count: int = 8
@export var kills_for_max_count: float = 50.0
@export var max_alive_zombies: int = 50
var spawn_timer: float = 0.0
@onready var team_score_bar: ProgressBar = $CanvasLayer/Control/team_score_bar
@onready var teamwork_label: Label = $CanvasLayer/Control/teamwork_label
@onready var health_bar: ProgressBar = $CanvasLayer/Control/health_bar
@onready var health_label: Label = $CanvasLayer/Control/health_label
@onready var kills_label: Label = $CanvasLayer/Control/kills_label
@onready var restart_btn: Button = $CanvasLayer/Control/restart_btn
@onready var final_score: Label = $CanvasLayer/Control/final_score

var game_frozen: bool = false

func _ready() -> void:
	global.player_health = 100.0
	global.teamwork_score = 50.0
	global.kills = 0
	global.dead = false
	game_frozen = false
	get_tree().paused = false
	for child in zombie_spawn.get_children():
		if child is CollisionShape2D:
			zombie_spawn_shapes.append(child)
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	if global.dead and not game_frozen:
		kills_label.visible = false
		health_label.visible = false
		health_bar.visible = false
		teamwork_label.visible = false
		team_score_bar.visible = false
		
		restart_btn.visible = true
		final_score.visible = true

		get_tree().paused = true
		game_frozen = true

	if game_frozen:
		return

	if global.teamwork_score < 0:
		global.teamwork_score = 0
	elif global.teamwork_score > 100:
		global.teamwork_score = 100
	
	health_bar.value = global.player_health
	team_score_bar.value = global.teamwork_score
	kills_label.text = str(global.kills)
	final_score.text = str(global.kills)
	
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_horde()
		spawn_timer = get_current_spawn_interval()
func get_current_spawn_interval() -> float:
	var ratio = clamp(float(global.kills) / kills_for_min_interval, 0.0, 1.0)
	return lerp(base_spawn_interval, min_spawn_interval, ratio)
func get_current_spawn_count() -> int:
	var ratio = clamp(float(global.kills) / kills_for_max_count, 0.0, 1.0)
	return int(round(lerp(float(base_spawn_count), float(max_spawn_count), ratio)))
func spawn_horde() -> void:
	var alive_count = get_tree().get_nodes_in_group("zombie").size()
	var room_available = max_alive_zombies - alive_count
	if room_available <= 0:
		return
	var count = min(get_current_spawn_count(), room_available)
	for i in range(count):
		spawn_zombie()
func spawn_zombie() -> void:
	if zombie_spawn_shapes.is_empty():
		return
	var chosen_shape_node: CollisionShape2D = zombie_spawn_shapes[randi() % zombie_spawn_shapes.size()]
	var shape = chosen_shape_node.shape
	var spawn_pos: Vector2
	if shape is RectangleShape2D:
		var half_size = shape.size / 2.0
		spawn_pos = chosen_shape_node.global_position + Vector2(
			randf_range(-half_size.x, half_size.x),
			randf_range(-half_size.y, half_size.y)
		)
	elif shape is CircleShape2D:
		var angle = randf_range(0, TAU)
		var dist = sqrt(randf()) * shape.radius
		spawn_pos = chosen_shape_node.global_position + Vector2(cos(angle), sin(angle)) * dist
	else:
		spawn_pos = chosen_shape_node.global_position
	var zombie = zombie_scene.instantiate()
	zombie.global_position = spawn_pos
	add_child(zombie)

func _on_restart_btn_pressed() -> void:
	get_tree().reload_current_scene()
