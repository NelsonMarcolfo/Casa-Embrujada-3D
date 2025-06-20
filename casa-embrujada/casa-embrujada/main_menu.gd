extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://help.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")
	
