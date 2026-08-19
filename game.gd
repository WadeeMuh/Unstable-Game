extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	camera.global_position = player.global_position + (mouse_pos - player.global_position) * 0.25
	print(player.global_position)
