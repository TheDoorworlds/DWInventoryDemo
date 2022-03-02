extends CenterContainer

var is_menu_open := false

onready var game_menu := $UIGameMenu


func _ready() -> void:
	is_menu_open = false
	game_menu.set_process_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !is_menu_open:
			game_menu.show()
			game_menu.set_process_input(true)
			is_menu_open = true
		else:
			game_menu.hide()
			game_menu.set_process_input(false)
			is_menu_open = false
		
