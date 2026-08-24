extends Area2D

var time_limit = 3

@export var base_heal_amount: float = 15.0
@export var min_heal_amount: float = 2.5
@export var max_heal_amount: float = 25.0
@export var score_neutral: float = 50.0
@export var score_min: float = 0.0
@export var score_max: float = 100.0

func _ready() -> void:
	z_index = int(global_position.y)

func _physics_process(delta: float) -> void:
	time_limit -= delta
	if time_limit <= 0:
		global.teamwork_score -= 3
		queue_free()

func get_current_heal_amount() -> float:
	var heal: float
	if global.teamwork_score >= score_neutral:
		var ratio = (global.teamwork_score - score_neutral) / (score_max - score_neutral)
		ratio = clamp(ratio, 0.0, 1.0)
		heal = lerp(base_heal_amount, max_heal_amount, ratio)
	else:
		var ratio = (score_neutral - global.teamwork_score) / (score_neutral - score_min)
		ratio = clamp(ratio, 0.0, 1.0)
		heal = lerp(base_heal_amount, min_heal_amount, ratio)
	return heal

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		global.teamwork_score += 1.5
		global.player_health += get_current_heal_amount()
		if global.player_health > 100:
			global.player_health = 100
		queue_free()
