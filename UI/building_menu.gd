extends Control

@export var building_placer: Node3D
@onready var building_resources: Array[BuildingData] = get_tree().current_scene.find_child("BuildingResources").building_resources
@onready var resource_manager = get_tree().current_scene.find_child("ResourceManager")
var building_buttons: Array[Button]  # Assign building buttons in the editor

func _ready():
	# Connect each button's signal dynamically, using Callable to pass the index
	for child in get_children():
		if child is Button:
			building_buttons.append(child)
	
	for i in range(building_buttons.size()):
		building_buttons[i].connect("pressed", Callable(self, "_on_building_button_pressed").bind(i))
		
	resource_manager.resources_updated.connect(on_resources_updated)
	check_buttons_available()

# Method that gets called when a building button is pressed
func _on_building_button_pressed(index: int):
	building_placer.on_building_selected(index)
	var building = building_resources[index]

func on_resources_updated():
	check_buttons_available()

func check_buttons_available():
	for i in building_buttons.size():
		if can_create_building(building_resources[i].production_cost, resource_manager.resources):
			building_buttons[i].disabled = false
		else:
			building_buttons[i].disabled = true

func can_create_building(cost: Dictionary, resources: Dictionary) -> bool:
	for resource in cost.keys():
		# If the resource is missing or the available amount is less than the cost
		if resources.get(resource, 0) < cost[resource]:
			return false  # Not enough resources to produce the unit
	return true  # All required resources are available
