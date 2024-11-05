extends CharacterBody3D  # or RigidBody3D if you use physics-based bullets

class_name Bullet

@export var speed: float = 50.0
@export var lifetime: float = 3.0
@export var damage: int = 10  # Bullet damage

var team = null
var direction: Vector3
var life_timer: Timer
var has_hit: bool = false  # To track if the bullet has already hit an enemy

func _ready():
	# Initialize a timer to destroy the bullet after its lifetime expires
	life_timer = Timer.new()
	life_timer.wait_time = lifetime
	life_timer.one_shot = true
	add_child(life_timer)
	life_timer.start()
	life_timer.connect("timeout", Callable(self, "_on_LifeTimer_timeout"))

# Function to set the bullet's movement direction
func set_direction(dir: Vector3):
	direction = dir.normalized()


# Move the bullet forward
func _physics_process(_delta: float):
	velocity = direction * speed
	move_and_slide()

# Destroy the bullet after the lifetime expires
func _on_LifeTimer_timeout() -> void:
	queue_free()

# Handle collision with bodies
func _on_area_3d_body_entered(body: Node3D) -> void:
	# If the bullet has already hit something, do nothing
	if has_hit:
		return  
	
	# Check if the body belongs to the opposite team and is a valid target
	if body.team and body.team != team:
		# Ensure the body has a health component and apply damage
		if body.has_node("HealthComponent"):
			body.get_node("HealthComponent").take_damage(damage)  # Apply damage

		# Mark that the bullet has hit something and destroy it
		has_hit = true
		queue_free()
