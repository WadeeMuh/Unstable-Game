extends Area2D

var time_limit = 4
var heal_amount: float = 15.0

func _ready() -> void:
	z_index = int(global_position.y)

func _physics_process(delta: float) -> void:
	time_limit -= delta
	if time_limit <= 0:
		global.teamwork_score -= 3
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		global.teamwork_score += 3
		global.player_health += heal_amount
		if global.player_health > 100:
			global.player_health = 100
		queue_free()
