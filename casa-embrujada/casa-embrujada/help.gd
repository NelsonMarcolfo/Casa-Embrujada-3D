extends Control

func _ready():
	# Asegurarse de que el control puede recibir input
	set_process_input(true)

func _input(event):
	# Verificar si se presionó la tecla Z
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_Z and event.pressed):
		# Cambiar a la escena del menú principal
		get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_help_pressed() -> void:
	pass # Replace with function body.

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://help.tscn")
