# Camera3D.gd
extends Node3D

@export var camera: Camera3D

@export var unit_group: Array = []
@onready var selection_rect_control := $Control  # Reference to the Control node for drawing

@onready var building_placer = get_parent().get_node("BuildingPlacer")

var selection_start: Vector2
var selection_end: Vector2
var is_selecting: bool = false
var selected_units: Array = []

var selected_building: Building = null

var single_click_threshold := 5  # Threshold to distinguish click vs drag
var is_single_click: bool = false

func _ready() -> void:
	# Ensure the Control node is set to ignore input for this to work
	selection_rect_control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _physics_process(_delta):
	unit_group = get_tree().get_nodes_in_group("units")
	selected_units = get_tree().get_nodes_in_group("selected_units")
	
	if Input.is_action_just_pressed("mouse_right"):
		#handle_right_click()
		pass

func _input(event: InputEvent) -> void:
	if not building_placer.placing:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					selection_start = get_viewport().get_mouse_position()
					selection_end = selection_start
					is_selecting = true
					is_single_click = true  # Assume it's a single click initially
					selection_rect_control.start_selection(selection_start)
				else:
					if is_selecting:
						# Check if the mouse was dragged far enough to be considered a rectangle selection
						if selection_start.distance_to(selection_end) > single_click_threshold:
							select_units_in_rectangle()
						else:
							select_single_unit()  # Handle single unit selection
						is_selecting = false
						selection_rect_control.end_selection()

		elif event is InputEventMouseMotion and is_selecting:
			selection_end = get_viewport().get_mouse_position()
			selection_rect_control.update_selection(selection_end)
			is_single_click = false  # If the mouse is moving, it's not a single click anymore

func select_units_in_rectangle() -> void:
	# Deselect all units initially
	deselect_all_units()

	# Convert 3D unit positions to 2D screen positions and check if they are within the rectangle
	var viewport = get_viewport()
	var screen_rect = Rect2(selection_start, selection_end - selection_start).abs()

	for unit in unit_group:
		var screen_pos = viewport.get_camera_3d().unproject_position(unit.global_position)
		if screen_rect.has_point(screen_pos):
			select_unit(unit)

func select_single_unit() -> void:
	# Perform raycast to find unit under the mouse cursor
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 10000
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var collision = space.intersect_ray(ray_query)

	# If a unit is clicked, toggle its selection
	if collision.size() > 0 and collision.has("collider"):
		var clicked_object = collision["collider"]
		if clicked_object is Unit:
			var clicked_unit = clicked_object
			if clicked_unit in unit_group:
				deselect_all_units()  # Deselect all other units
				deselect_building()
				select_unit(clicked_unit)  # Select the clicked unit
				
		elif clicked_object is Building:
			deselect_all_units()
			deselect_building()
			select_building(clicked_object)
		else:
			deselect_all_units()
			deselect_building()

func select_unit(unit: CharacterBody3D) -> void:
	# Custom logic for selecting a unit, e.g., changing its material, outline, etc.
	unit.selection.select()  # Assumes your unit script has a select() method
	unit.add_to_group("selected_units")
	#selected_units.append(unit)

func deselect_unit(unit: CharacterBody3D) -> void:
	# Custom logic for deselecting a unit
	unit.selection.deselect()  # Assumes your unit script has a deselect() method
	unit.remove_from_group("selected_units")
	#selected_units.erase(unit)

func deselect_all_units() -> void:
	# Deselect all currently selected units
	for unit in selected_units:
		unit.selection.deselect()  # Assumes your unit script has a deselect() method
		unit.remove_from_group("selected_units")
	#selected_units.clear()

func select_building(building):
	selected_building = building
	if selected_building.menu:
		selected_building.menu.show()
	building.selection.select()
	
func deselect_building():
	if selected_building:
		if selected_building.menu:
			selected_building.menu.hide()
		selected_building.selection.deselect()
		selected_building = null
