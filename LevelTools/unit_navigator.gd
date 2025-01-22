extends Node3D

@export var camera: Camera3D

@export var target:Marker3D

@onready var selected_units = get_tree().get_nodes_in_group("selected_units")

@onready var nav_region = get_parent().get_node("NavigationRegion3D")

var unit_size: float = 1.2
var destination_positions: Array[Vector3] = []

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	selected_units = get_tree().get_nodes_in_group("selected_units")
	if Input.is_action_just_pressed("mouse_right"):
		give_order()

func give_order():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_length = 10000
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var collision = space.intersect_ray(ray_query)
	
	if(not collision.is_empty()):
		if collision.collider.is_in_group("enemies"):
			issue_attack_order(collision.collider)
			return
		else:
			target.position = collision.position
			move_units_to(target.position)
	
func move_units_to(target_position: Vector3):
	if selected_units.is_empty():
		return
	
	calculate_box_positions(target_position)

	for i in range(selected_units.size()):
		var unit = selected_units[i]
		var destination = destination_positions[i]
		move_unit_to(unit, destination)

func move_unit_to(unit, target_position: Vector3):
	#var path = NavigationServer3D.map_get_path(nav_region.get_navigation_map(), unit.global_transform.origin, target_position, false)

	# Move as close as possible
	var closest_point = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), target_position)
	
	unit.current_target = null
	unit.movement_component.move_to(closest_point)
	
func issue_attack_order(attack_target):
	for unit in selected_units:
		if attack_target.team and unit.team and (attack_target.team != unit.team):
			unit.look_at(attack_target.position)
			unit.attack_component.target = attack_target
			unit.current_target = attack_target
			#unit.attack_component.attack_target(attack_target)
			unit.movement_component.follow_target(attack_target)

func calculate_box_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var row_length = ceil(sqrt(num_units)) # Number of units per row
	var column_length = ceil(num_units / row_length) # Number of units per column

	# Recalculate to balance rows and columns
	if row_length * (column_length - 1) >= num_units:
		column_length -= 1

	# Calculate the starting point to center the formation around the target position
	var half_width = (row_length - 1) * unit_size / 2
	var half_height = (column_length - 1) * unit_size / 2

	for i in range(num_units):
		var row = i / int(row_length)
		var col = i % int(row_length)

		var position_x = target_position.x - half_width + col * unit_size
		var position_z = target_position.z - half_height + row * unit_size
		var new_position = Vector3(position_x, target_position.y, position_z)

		destination_positions.append(new_position)
