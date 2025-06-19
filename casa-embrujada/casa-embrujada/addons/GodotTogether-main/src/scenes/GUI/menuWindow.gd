@tool
extends PopupPanel
class_name GodotTogetherMenuWindow

var main: GodotTogether

func _ready() -> void:
	await get_tree().physics_frame
	
	if main:
		$about/scroll/vbox/version.text = "Version: " + GodotTogether.VERSION

func get_menu() -> GodotTogetherMenu:
	return $main
