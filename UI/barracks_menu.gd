extends Control

@onready var unit_selector = get_tree().current_scene.find_child("UnitSelector")
@onready var unit_resources: Array[UnitData] = get_tree().current_scene.find_child("UnitResources").unit_resources
@onready var resource_manager = get_tree().current_scene.find_child("ResourceManager")
@onready var game_manager = get_tree().current_scene.find_child("GameManager")

var unit_buttons = []

func _ready():
	# Connect each button's signal dynamically, using Callable to pass the index
	for child in $Panel/UnitButtons.get_children():
		if child is Button:
			unit_buttons.append(child)
	
	for i in range(unit_buttons.size()):
		unit_buttons[i].connect("pressed", Callable(self, "_on_unit_button_pressed").bind(i))
		
		unit_buttons[i].text = unit_resources[i].unit_name
		var label = unit_buttons[i].find_child("ProductionCost")
		if label:
			var cost_text = ""
			for key in unit_resources[i].production_cost.keys():
				cost_text += key + ": " + str(unit_resources[i].production_cost[key]) + "\n"
			
			label.text = str(cost_text)
		
	resource_manager.resources_updated.connect(on_resources_updated)
	game_manager.population_changed.connect(on_population_changed)
	check_buttons_available()

# Method that gets called when a building button is pressed
func _on_unit_button_pressed(index: int):
	var unit = unit_resources[index]
	resource_manager.substract_resources(unit["production_cost"])
	produce_unit(index)

func on_resources_updated():
	check_buttons_available()

func can_produce_unit(cost: Dictionary, resources: Dictionary) -> bool:
	var queue_population = 0
	if not is_instance_valid(unit_selector.selected_building):
		return false
	if unit_selector.selected_building is Barracks:
		queue_population = unit_selector.selected_building.production_queue.unit_queue.size()
	
	if game_manager.current_population + queue_population >= game_manager.max_population:
		return false
	for resource in cost.keys():
		# If the resource is missing or the available amount is less than the cost
		if resources.get(resource, 0) < cost[resource]:
			return false  # Not enough resources to produce the unit
	return true  # All required resources are available
	
func check_buttons_available():
	for i in unit_buttons.size():
		if can_produce_unit(unit_resources[i].production_cost, resource_manager.resources):
			unit_buttons[i].disabled = false
		else:
			unit_buttons[i].disabled = true

func on_population_changed():
	check_buttons_available()
	
func produce_unit(index):
	var selected_building = unit_selector.selected_building
	if is_instance_valid(selected_building):
		var unit_resource = unit_resources[index]
		selected_building.production_queue.add_unit_to_queue(
			index, 
			unit_resource.unit_name, 
			unit_resource.production_time,
		)

func _on_panel_mouse_entered() -> void:
	print("sub entered")
	unit_selector.mouse_on_ui = true

func _on_panel_mouse_exited() -> void:
	print("sub exited")
	unit_selector.mouse_on_ui = false
