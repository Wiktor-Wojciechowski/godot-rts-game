extends Node3D

@export var camera: Camera3D
@export var ui: Control

@onready var selection_rect_control := $Selector2D # Reference to the Control node for drawing

@onready var building_placer = get_parent().get_node("BuildingPlacer")

var unit_group: Array = []

var can_select = true

var selection_start: Vector2
var selection_end: Vector2
var is_selecting: bool = false
var selected_units: Array = []

var selected_building: Building = null

var single_click_threshold := 5  # Threshold to distinguish click vs drag
var is_single_click: bool = false

var sub_menu = null

func _ready() -> void:
	selection_rect_control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _physics_process(_delta):
	unit_group = get_tree().get_nodes_in_group("units")
	selected_units = get_tree().get_nodes_in_group("selected_units")
	
	if Input.is_action_just_pressed("mouse_right"):
		pass

func _input(event: InputEvent) -> void:
	if can_select:
		if not building_placer.placing:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if event.double_click:
						select_units_by_type()
						print("double")
					else:
						if event.pressed:
							selection_start = get_viewport().get_mouse_position()
							selection_end = selection_start
							is_selecting = true
							is_single_click = true
							selection_rect_control.start_selection(selection_start)
						else:
							if is_selecting:
								# Check if the mouse was dragged far enough to be considered a rectangle selection
								if selection_start.distance_to(selection_end) > single_click_threshold:
									select_units_in_rectangle()
								else:
									select_single_unit() 
								is_selecting = false
								selection_rect_control.end_selection()
			elif event is InputEventMouseMotion and is_selecting:
				selection_end = get_viewport().get_mouse_position()
				selection_rect_control.update_selection(selection_end)
				is_single_click = false

func select_units_in_rectangle() -> void:
	deselect_all_units()

	# Convert 3D unit positions to 2D screen positions and check if they are within the rectangle
	var viewport = get_viewport()
	var screen_rect = Rect2(selection_start, selection_end - selection_start).abs()

	for unit in unit_group:
		if is_instance_valid(unit):
			var screen_pos = viewport.get_camera_3d().unproject_position(unit.global_position)
			if screen_rect.has_point(screen_pos):
				select_unit(unit)

func select_single_unit() -> void:
	var collision = cast_ray_from_mouse()

	if collision.size() > 0 and collision.has("collider"):
		var clicked_object = collision["collider"]
		if clicked_object is Unit:
			var clicked_unit = clicked_object
			if clicked_unit in unit_group:
				deselect_all_units()
				deselect_building()
				select_unit(clicked_unit)
				
		elif clicked_object is Building:
			deselect_all_units()
			deselect_building()
			select_building(clicked_object)
		else:
			deselect_all_units()
			deselect_building()

func select_unit(unit: CharacterBody3D) -> void:
	if is_instance_valid(unit):
		unit.selection.select()
		unit.add_to_group("selected_units")

func deselect_unit(unit: CharacterBody3D) -> void:
	if is_instance_valid(unit):
		unit.selection.deselect()
		unit.remove_from_group("selected_units")


func deselect_all_units() -> void:
	for unit in selected_units:
		if is_instance_valid(unit):
			deselect_unit(unit)

func select_building(building):
	selected_building = building
	if selected_building.menu:
		sub_menu = selected_building.menu.instantiate()
		ui.add_child(sub_menu)
	building.selection.select()
	
func deselect_building():
	if selected_building and is_instance_valid(selected_building):
		if selected_building.menu:
			ui.remove_child(sub_menu)
			sub_menu.queue_free()
		selected_building.selection.deselect()
		selected_building = null

func _on_ui_mouse_entered() -> void:
	if not is_selecting:
		can_select = false

func _on_ui_mouse_exited() -> void:
	can_select = true

func select_units_by_type():
	var collision = cast_ray_from_mouse()
	if collision.size() > 0 and collision.has("collider"):
		var clicked_object = collision["collider"]
		if clicked_object is Unit:
			var unit_type = clicked_object.unit_name
			for unit in unit_group:
				if unit.unit_name == unit_type:
					select_unit(unit)

func cast_ray_from_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 10000
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var collision = space.intersect_ray(ray_query)
	return collision
	
