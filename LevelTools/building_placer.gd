extends Node3D

@export var buildings: Array[PackedScene]
@export var camera: Camera3D
@export var nav_region: NavigationRegion3D

@onready var building_resources = get_parent().get_node("BuildingResources").building_resources
@onready var resource_manager = get_parent().get_node("ResourceManager")

var structures: Node3D

var current_building_index = -1
var current_building_ghost: Node3D

var base_building_color: Color 

var placing = false

signal building_placed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	structures = get_tree().current_scene.find_child("Structures")
	for building in structures.get_children():
		building.building_destroyed.connect(on_building_destroyed)
	nav_region.bake_navigation_mesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not placing:
		pass
	else:
		update_building_ghost_positon()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if placing:	
				place_building()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_placement()

func on_building_selected(index: int) -> void:
	# Begin placing the building
	placing = true
	# If a ghost building already exists, free it
	if current_building_ghost:
		current_building_ghost.queue_free()
	
	# Set the selected building index
	current_building_index = index
	# Instantiate a new ghost building
	current_building_ghost = buildings[current_building_index].instantiate()
	#Disable the ghost process
	current_building_ghost.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Get the MeshInstance3D node from the ghost building
	var ghost_children = current_building_ghost.get_children()
	for child in ghost_children:
		if child is MeshInstance3D:
			var mesh_instance = child
			var material = mesh_instance.get_active_material(0)
			if material:
				base_building_color = material.albedo_color
				var new_material = material.duplicate()
				new_material.albedo_color.a = 0.5  
				new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				new_material.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
				mesh_instance.set_surface_override_material(0, new_material)
	
	add_child(current_building_ghost)
	#Put the building below the ground so it doesn't appear in the middle of the map
	current_building_ghost.global_position -= Vector3(0, 100, 0)

func update_building_ghost_positon():
	var mesh = current_building_ghost.get_node("WrongPlacementIndicator")
	var material = mesh.get_active_material(0)
	if not is_placement_valid():
		mesh.show()
		material.albedo_color = Color(1,0,0, 1)	
		
	else:
		material.albedo_color = base_building_color
		mesh.hide()
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 10000
	var from = camera.project_ray_origin(mouse_pos)
	
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = 1
	
	var collision = space.intersect_ray(ray_query)

	if current_building_ghost and collision:
		current_building_ghost.global_position = collision.position - Vector3(0, 0.5, 0)
	pass

func cancel_placement():
	if not placing:
		return
	placing = false
	current_building_ghost.queue_free()
	current_building_ghost = null
	current_building_index = -1

func is_placement_valid():
	#check collision with buildings
	var space_state = get_world_3d().direct_space_state
	
	# Get the collision shape of the building
	var collision_shape = current_building_ghost.get_node("CollisionShape3D").shape
	# Create a Transform3D for the building's global position and orientation
	var building_transform = current_building_ghost.global_transform
	# Check for collisions using intersect_shape
	var collision_params = PhysicsShapeQueryParameters3D.new()
	collision_params.shape = collision_shape
	collision_params.transform = building_transform
	collision_params.collide_with_bodies = true
	collision_params.collide_with_areas = true
	collision_params.collision_mask = 31 #1 + 2 + 3 + 4 + 7
	# Check if the building is colliding with other objects
	var collision = space_state.intersect_shape(collision_params)

	if collision.size() > 1: #must be more than 1 as the shape is colliding with the ghost
		return false
	
	#Check if corners on ground
	var colshape = current_building_ghost.get_node("CollisionShape3D")
	var area_collision_shape: BoxShape3D = colshape.get_shape()
	var area_size: Vector3 = area_collision_shape.size * 0.5
	var points_to_check: Array = [
		colshape.global_position + Vector3(area_size.x, -area_size.y, area_size.z),
		colshape.global_position + Vector3(area_size.x, -area_size.y, -area_size.z),
		colshape.global_position + Vector3(-area_size.x, -area_size.y, -area_size.z),
		colshape.global_position + Vector3(-area_size.x, -area_size.y, area_size.z)
	]
	
	for point in points_to_check:
		var ray_from = point
		var ray_to = ray_from + Vector3(0, -10, 0)
		var ray_query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		ray_query.collision_mask = 1
		ray_query.hit_from_inside = true
		
		var raycast_result = get_world_3d().get_direct_space_state().intersect_ray(ray_query)
		if not raycast_result:
			return false
		
	return true

func place_building():
	if not is_placement_valid():
		return
	
	#Take resources
	var building_cost = building_resources[current_building_index].production_cost
	resource_manager.substract_resources(building_cost)
	
	var building_instance = buildings[current_building_index].instantiate()
	
	structures.add_child(building_instance)
	
	if building_instance.team == 1:
		if building_instance.has_node("OmniLight3D"):
			building_instance.get_node("OmniLight3D").show()
			
	building_instance.building_destroyed.connect(on_building_destroyed)
	
	var mesh = building_instance.get_node("MeshInstance3D")
	var material = mesh.get_active_material(0)
	material.albedo_color.a = 1
	
	building_instance.global_transform.origin = current_building_ghost.global_transform.origin
	
	# Free the ghost building
	current_building_ghost.queue_free()
	current_building_ghost = null
	current_building_index = -1
			
	placing = false
	
	if not nav_region.is_baking():
		nav_region.bake_navigation_mesh()

func on_building_destroyed(building):
	if not nav_region.is_baking():
		nav_region.bake_navigation_mesh()
