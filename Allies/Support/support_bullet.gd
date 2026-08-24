extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var speed = 300

func _ready():
	global_position = pos
	global_rotation = rota

func _physics_process(_delta):
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	if global.teamwork_score <= 0:
		queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("zombie_hitbox_method"):
		queue_free()
