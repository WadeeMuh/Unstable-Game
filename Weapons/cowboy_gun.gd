extends CharacterBody2D

var bullet_path = preload("res://Weapons/cowboy_bullet.tscn")
var shoot_cooldown: float = 0
var mag: int = 6
var reload_ready: bool = false

@onready var bullet_spawn: Marker2D = $"bullet-spawn"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $"../Camera2D"

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	
	if !global.dodging:
		if Input.is_action_pressed('shoot'):
			fire_gun()
		
		if Input.is_action_just_pressed('reload') and reload_ready:
			reload()
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
		
	if global.dodging:
		visible = false
		if animated_sprite.animation == "reload":
			animated_sprite.animation = "default"
	else:
		visible = true

func fire_gun():
	if mag > 0 and shoot_cooldown <= 0:
		animated_sprite.play("shoot")
		camera.add_trauma(0.5)
		var bullet = bullet_path.instantiate()
		bullet.dir = rotation
		bullet.pos = bullet_spawn.global_position
		bullet.rota = global_rotation
		get_parent().add_child(bullet)
		shoot_cooldown += 0.5
		mag -= 1
		reload_ready = false

func reload():
	animated_sprite.play("reload")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "reload":
		mag = 6
		reload_ready = false
	elif animated_sprite.animation == "shoot":
		reload_ready = true
