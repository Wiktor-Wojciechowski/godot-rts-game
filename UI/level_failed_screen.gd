extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/RetryButton.pressed.connect(on_retry_button_pressed)
	$Panel/ExitToMainMenuButton.pressed.connect(on_exit_to_main_menu_button_pressed)


func on_retry_button_pressed():
	get_tree().reload_current_scene()

func on_exit_to_main_menu_button_pressed():
	LevelsManager.go_to_main_menu()
