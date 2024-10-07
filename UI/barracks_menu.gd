extends Control

@onready var unit_selector = get_tree().current_scene.find_child("UnitSelector")
var unit_buttons = []

func _ready():
	# Connect each button's signal dynamically, using Callable to pass the index
	for child in get_children():
		if child is Button:
			unit_buttons.append(child)
	
	for i in range(unit_buttons.size()):
		unit_buttons[i].connect("pressed", Callable(self, "_on_unit_button_pressed").bind(i))

# Method that gets called when a building button is pressed
func _on_unit_button_pressed(index: int):
	unit_selector.on_produce_unit(index)
