extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if collision_shape and collision_shape.shape is CircleShape2D:
		var radius = collision_shape.shape.radius
		
		draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color.BLACK, 1.0)
