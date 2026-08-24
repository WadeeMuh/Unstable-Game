extends Control

func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Game.tscn")

func _on_how_to_play_btn_pressed() -> void:
	$how_to_play_btn.visible = false
	$Label.visible = true
	$Label3.visible = true
	$Label4.visible = true
