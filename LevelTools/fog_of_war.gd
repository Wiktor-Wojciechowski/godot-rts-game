extends Node3D

# Fog of War Settings
@export var fog_texture_size: int = 512 # Resolution of the fog texture
@export var fog_radius: float = 10.0 # Radius of visibility in world units
@export var units: Array = [] # Array of units to reveal fog
@export var level_origin: Vector3 = Vector3.ZERO # The world origin for fog (center of the level)

var fog_texture: ImageTexture
var fog_image: Image

func _ready():
	# Initialize fog texture and image
	units = get_parent().get_node("Units").get_children()
	initialize_fog_texture()
	create_fog_mesh()

func initialize_fog_texture():
	fog_image = Image.create(fog_texture_size, fog_texture_size, false, Image.FORMAT_RGBA8)
	fog_image.fill(Color(0, 0, 0, 1)) # Unexplored areas are black
	fog_texture = ImageTexture.create_from_image(fog_image)
	update_fog_texture()

func create_fog_mesh():
	# Create material and mesh for fog
	var fog_material = StandardMaterial3D.new()
	fog_material.albedo_texture = fog_texture
	fog_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var fog_mesh = MeshInstance3D.new()
	fog_mesh.mesh = PlaneMesh.new()
	fog_mesh.material_override = fog_material
	fog_mesh.scale = Vector3(100, 1, 100) # Adjust to your level size
	add_child(fog_mesh)

func update_fog_texture():
	fog_texture.update(fog_image)

func reveal_area(center: Vector3):
	# Convert world coordinates to texture space
	var world_to_texture = fog_texture_size / 200.0 # Adjust to your level scale (can change this based on the world size)
	
	# Offset the position based on the level origin and center the world coordinates
	var center_x = int((center.x - level_origin.x) * world_to_texture + fog_texture_size / 2)
	var center_y = int((center.z - level_origin.z) * world_to_texture + fog_texture_size / 2)

	# Iterate within the radius to reveal circular areas
	for y in range(-fog_radius, fog_radius + 1):
		for x in range(-fog_radius, fog_radius + 1):
			if Vector2(x, y).length() <= fog_radius:
				var texture_x = clamp(center_x + x, 0, fog_texture_size - 1)
				var texture_y = clamp(center_y + y, 0, fog_texture_size - 1)
				fog_image.set_pixel(texture_x, texture_y, Color(1, 1, 1, 0)) # Transparent

func reveal_fog():
	# Clear the fog texture
	fog_image.fill(Color(0, 0, 0, 1))
	
	# Reveal fog around units
	for  unit in units:
		if is_instance_valid(unit) and unit.is_inside_tree():
			reveal_area(unit.global_transform.origin)
	
	update_fog_texture()

func _process(delta: float):
	reveal_fog()
