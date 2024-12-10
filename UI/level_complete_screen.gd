extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/NextLevelButton.pressed.connect(on_next_level_button_pressed)
	$Panel/ExitToMainMenuButton.pressed.connect(on_exit_to_main_menu_button_pressed)
	if not LevelsManager.can_load_next_level():
		$Panel/NextLevelButton.disabled = true

func on_next_level_button_pressed():
	LevelsManager.load_next_level()

func on_exit_to_main_menu_button_pressed():
	LevelsManager.go_to_main_menu()
