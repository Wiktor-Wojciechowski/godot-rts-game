# Sentry.gd
extends Building

class_name Sentry

@export var detection_range: float = 20.0
@export var rotation_speed: float = 1.5
@export var shooting_interval: float = 1.0
@export var bullet_scene: PackedScene
@export var bullet_damage:int = 10
@export var angle_margin: float = 0.1  # Margin for rotation precision
@export var target_group: String

var current_target: Node3D = null
var can_shoot: bool = true
var enemies_in_range: Array = []  # List to track enemies in range

# Child Nodes
var area: Area3D
var timer: Timer
var head: StaticBody3D

func _ready():
	super._ready()
	match team:
		1: 
			target_group = "enemies"
			
		2: target_group = "units"
	#Set area3d collision radius to detection range
	area = $Area3D 
	var area_col = area.get_node("CollisionShape3D")
	area_col.shape.radius = detection_range
	
	timer = $Timer
	timer.wait_time = shooting_interval
	timer.one_shot = false
	head = $Head
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	

# Function called when an enemy enters the detection area
func _on_body_entered(body: Node) -> void:
	print(body)
	if body.is_in_group(target_group):
		# Add the enemy to the list of enemies in range
		enemies_in_range.append(body)

		# If there is no current target, acquire the new one
		if current_target == null:
			current_target = body

# Function called when an enemy exits the detection area
func _on_body_exited(body: Node) -> void:
	if body.is_in_group(target_group):
		# Remove the enemy from the list of enemies in range
		enemies_in_range.erase(body)

		# If the exiting enemy is the current target, find a new one
		if body == current_target:
			if enemies_in_range.size() > 0:
				# Acquire a new target (you can choose the closest one)
				current_target = _find_closest_enemy()
			else:
				# No enemies left in range
				current_target = null

# Physics process for rotating and shooting
func _physics_process(delta: float):
	if current_target:
		_rotate_toward_target(delta)
		# Check if the sentry is fully rotated toward the target before shooting
		if _is_fully_rotated() and can_shoot:
			_shoot()

# Function to rotate the sentry toward the target
func _rotate_toward_target(delta: float):
	var target_dir = (current_target.global_transform.origin - head.global_transform.origin).normalized()
	var up_vector = Vector3.FORWARD
	# Check if the target direction is parallel to Vector3.UP
	if abs(target_dir.dot(Vector3.UP)) > 0.99:
		# If they are parallel, use another up vector, for example Vector3.FORWARD
		up_vector = Vector3.FORWARD
	else:
		up_vector = Vector3.UP

	# Calculate the target rotation using slerp
	var target_rotation = head.global_transform.basis.get_rotation_quaternion().slerp(
		head.global_transform.looking_at(current_target.global_transform.origin, up_vector).basis.get_rotation_quaternion(),
		rotation_speed * delta
	)
	# Preserve the original scale
	var current_scale = head.global_transform.basis.get_scale()
	# Create a new basis from the target rotation
	var new_basis = Basis(target_rotation)
	# Manually apply the original scale
	new_basis = new_basis.scaled(current_scale)
	# Update the head's global transform with the new basis (rotation) and preserved scale
	head.global_transform.basis = new_basis

func _is_fully_rotated() -> bool:
	# Get the direction the sentry is facing
	var forward_dir = -head.global_transform.basis.z.normalized()
	# Get the direction toward the target
	var target_dir = (current_target.global_transform.origin - head.global_transform.origin).normalized()
	# Calculate the dot product between the forward direction and target direction
	var dot_product = forward_dir.dot(target_dir)
	# Check if the angle between the two directions is within the specified margin
	return dot_product > (1.0 - angle_margin)

# Shooting function
func _shoot():
	can_shoot = false
	var bullet_instance = bullet_scene.instantiate()
	
	bullet_instance.team = team
	
	get_parent().add_child(bullet_instance)

	# Set bullet's initial position at the sentry's location
	bullet_instance.global_transform.origin = $Head/BulletSpawner.global_transform.origin
	bullet_instance.damage = bullet_damage
	# Calculate the direction from the sentry to the target
	var bullet_direction = (current_target.global_transform.origin - $Head/BulletSpawner.global_transform.origin).normalized()

	# Set the bullet's direction
	bullet_instance.set_direction(bullet_direction)
	bullet_instance.look_at(current_target.position)

	# Start the timer for the next shot
	timer.start()

# Function called when timer finishes
func _on_timer_timeout() -> void:
	can_shoot = true

# Helper function to find the closest enemy
func _find_closest_enemy() -> Node3D:
	var closest_enemy = null
	var closest_distance = INF
	for enemy in enemies_in_range:
		var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy
