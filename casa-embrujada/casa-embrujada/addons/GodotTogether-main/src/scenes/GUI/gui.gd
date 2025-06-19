@tool
extends Node
class_name GodotTogetherGUI

var main: GodotTogether

func _ready() -> void:
	if main:
		var menu_window = get_menu_window()
		var menu = get_menu()
		
		menu_window.visible = false
		
		menu.gui = self
		menu.main = main
		
		menu.users.main = main

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		get_menu_window().visible = true

func get_menu() -> GodotTogetherMenu:
	return get_menu_window().get_menu()

func get_menu_window() -> GodotTogetherMenuWindow:
	return $mainMenu

func alert(text: String, title := "") -> AcceptDialog:
	var popup := AcceptDialog.new()
	
	popup.dialog_text = text
	popup.title = title
	popup.always_on_top = true

	add_child(popup)
	popup.popup_centered()

	popup.canceled.connect(popup.queue_free)
	popup.confirmed.connect(popup.queue_free)

	return popup

func confirm(text: String) -> bool:
	var p := ConfirmationDialog.new()
	p.dialog_text = text
	
	var status = null
	
	p.confirmed.connect(func(): status = true)
	p.canceled.connect(func(): status = false)
	
	add_child(p)
	p.popup_centered()
	
	while status == null:
		await get_tree().process_frame
	
	p.queue_free()
	
	return status
	

func visuals_available() -> bool:
	return main or not Engine.is_editor_hint() 
