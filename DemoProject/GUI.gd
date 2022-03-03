extends CanvasLayer

# Constants


# Export Variables


# Local Variables


# Public Variables
var menu_showing := false

# Node References
# Use the following to ensure references do not break when rearranging nodes:
# export(NodePath) onready var variable_name = get_node(variable_name) as NodeType
export(NodePath) onready var GAME_MENU = get_node(GAME_MENU) as Control


func _ready() -> void:
	menu_showing = false


# Input Handlers
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !menu_showing:
			GAME_MENU.show()
			GAME_MENU.set_process_unhandled_input(true)
			menu_showing = true
		else:
			GAME_MENU.hide()
			GAME_MENU.set_process_unhandled_input(false)
			menu_showing = false
		
			
		

# Boolean functions


# Signal receivers functions
