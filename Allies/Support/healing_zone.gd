extends Area2D

var time_limit = 4

func _ready() -> void:
	z_index = int(global_position.y)

func _physics_process(delta: float) -> void:
	time_limit -= delta
	if time_limit <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player_method"):
		global.player_health += 15
		if global.player_health > 100:
			global.player_health = 100
		queue_free()
