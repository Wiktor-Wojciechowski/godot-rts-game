extends Control

@export var building_placer: Node3D
var building_buttons: Array[Button]  # Assign building buttons in the editor

func _ready():
	# Connect each button's signal dynamically, using Callable to pass the index
	for child in get_children():
		if child is Button:
			building_buttons.append(child)
	
	for i in range(building_buttons.size()):
		building_buttons[i].connect("pressed", Callable(self, "_on_building_button_pressed").bind(i))

# Method that gets called when a building button is pressed
func _on_building_button_pressed(index: int):
	building_placer.on_building_selected(index)
