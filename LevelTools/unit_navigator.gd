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
		right_click()

func right_click():
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
	
# Issue a move command to selected units
func move_units_to(target_position: Vector3):
	if selected_units.is_empty():
		return
	
	# Calculate target positions around the main target position
	calculate_box_positions(target_position)

	# Assign each unit to a target position
	for i in range(selected_units.size()):
		var unit = selected_units[i]
		var destination = destination_positions[i]
		move_unit_to(unit, destination)

# Move a single unit to the target position
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

# Calculate target positions around the main target position
func calculate_target_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var radius = 1.5 * unit_size # Adjust radius based on the number of units
	var angle_step = 360.0 / max(num_units, 1)

	for i in range(num_units):
		var angle = deg_to_rad(i * angle_step)
		var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var new_position = target_position + offset
		destination_positions.append(new_position)
		
	print(destination_positions)
	
func calculate_spread_out_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var radius = 2.0 * unit_size # Increase the radius multiplier to spread units further apart
	var angle_step = 360.0 / max(num_units, 1)

	# To spread units more, we will increase the radius in steps as the number of units grows
	var units_per_ring = 8 # Number of units per concentric ring before increasing radius
	var ring_index = 0
	var current_ring_unit_count = 0

	for i in range(num_units):
		if current_ring_unit_count >= units_per_ring:
			# Move to the next ring
			ring_index += 1
			current_ring_unit_count = 0
			radius += unit_size * 2.0 # Increase the radius for the next ring

		var angle = deg_to_rad(current_ring_unit_count * (360.0 / units_per_ring))
		var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		var new_position = target_position + offset
		destination_positions.append(new_position)

		current_ring_unit_count += 1

func calculate_ring_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var units_placed = 0
	var radius = unit_size * 2.0 # Initial radius for the first ring
	var units_in_current_ring = 1

	while units_placed < num_units:
		# Calculate the number of units that can fit in the current ring
		var circumference = 2.0 * PI * radius
		var max_units_in_ring = floor(circumference / unit_size)

		# Angle step based on the number of units in this ring
		var angle_step = 2 * PI / max_units_in_ring

		for j in range(max_units_in_ring):
			if units_placed >= num_units:
				break

			var angle = j * angle_step
			var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			var new_position = target_position + offset
			destination_positions.append(new_position)

			units_placed += 1

		# Increase the radius for the next ring
		radius += unit_size * 2.0

func calculate_row_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var row_length = ceil(sqrt(num_units)) # Number of units per row

	# Determine starting offset to center the formation around the target position
	var formation_width = row_length * unit_size
	var formation_height = ceil(float(num_units) / row_length) * unit_size
	var start_x = target_position.x - formation_width / 2 + unit_size / 2
	var start_z = target_position.z - formation_height / 2 + unit_size / 2

	for i in range(num_units):
		var row = i / row_length
		var col = i % int(row_length)

		var position_x = start_x + col * unit_size
		var position_z = start_z + row * unit_size
		var new_position = Vector3(position_x, target_position.y, position_z)

		destination_positions.append(new_position)

func calculate_rounded_row_positions(target_position: Vector3):
	destination_positions.clear()

	var num_units = selected_units.size()
	var radius_step = unit_size * 1.5 # Adjust to control spacing between rows
	var current_radius = radius_step # Start at the first ring's radius
	var units_placed = 0

	while units_placed < num_units:
		# Calculate the number of units that can fit in the current rounded row
		var circumference = 2.0 * PI * current_radius
		var units_in_row = floor(circumference / unit_size)
		var angle_step = 2 * PI / max(units_in_row, 1)

		# Place units in the current rounded row
		for i in range(units_in_row):
			if units_placed >= num_units:
				break

			var angle = i * angle_step
			var offset = Vector3(cos(angle) * current_radius, 0, sin(angle) * current_radius)
			var new_position = target_position + offset
			destination_positions.append(new_position)

			units_placed += 1

		# Increase the radius for the next row
		current_radius += radius_step

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
