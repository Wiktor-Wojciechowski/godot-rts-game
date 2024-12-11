extends Control

func _ready() -> void:
	$Panel/VBoxContainer/ResumeButton.pressed.connect(on_resume_button_pressed)
	$Panel/VBoxContainer/OptionsButton.pressed.connect(on_options_button_pressed)
	$Panel/VBoxContainer/ExitToMainMenuButton.pressed.connect(on_exit_to_main_menu_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		if not visible:
			get_tree().paused = true
			show()
		else:
			print('hiding pause')
			get_tree().paused = false
			hide()
			
			
func on_resume_button_pressed():
	get_tree().paused = false
	hide()

func on_options_button_pressed():
	$OptionsMenu.show()

func on_exit_to_main_menu_button_pressed():
	get_tree().paused = false
	LevelsManager.go_to_main_menu()
