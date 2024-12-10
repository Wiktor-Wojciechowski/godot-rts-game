extends Control

var level_buttons = []

func _ready() -> void:
	$Panel/BackButton.pressed.connect(on_back_button_pressed)
	
	for margincontainer in $VBoxContainer.get_children():
		var button = margincontainer.get_child(0)
		level_buttons.append(button)
	
	for i in range(level_buttons.size()):
		var level_index = i+1
		level_buttons[i].pressed.connect(on_level_button_pressed.bind(level_index))
		level_buttons[i].disabled = not LevelsManager.can_load_level_with_index(level_index)

func on_level_button_pressed(index):
	LevelsManager.load_level(index)

func on_back_button_pressed():
	hide()
