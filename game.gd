extends Node2D

@onready var cowboy_gun: CharacterBody2D = $"cowboy-gun"
@onready var gun_spawn: Marker2D = $"Player/gun-spawn"

func _physics_process(_delta: float) -> void:
	cowboy_gun.global_position = gun_spawn.global_position
