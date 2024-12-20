extends CharacterBody3D

class_name Unit

@onready var selection = $Selection
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent
@onready var attack_component = $AttackComponent
@onready var movement_component = $MovementComponent

@export var can_attack_while_moving = false

@export var unit_resource: UnitData = null

var team = 1

var current_target = null

func _ready() -> void:
	if unit_resource:
		attack_component.attack_damage = unit_resource.attack
		movement_component.speed = unit_resource.movement_speed

func _process(delta):
	unit_behavior()

# Determines if the unit can attack the target
func can_attack_target(target) -> bool:
	# Check if the target is in range and we can attack
	if global_position.distance_to(target.global_position) > attack_component.attack_range:
		return false
	
	# Ensure attack timer and other conditions are met
	return attack_component.can_attack and not (movement_component.moving and not can_attack_while_moving)

# Perform the attack on the current target
func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)
	
func unit_behavior():
	if not current_target and not movement_component.moving:
		current_target = attack_component._find_closest_enemy()
		
	if current_target:
		if not is_instance_valid(current_target) or current_target.team == team:
			current_target = null
			return
		
		movement_component.follow_target(current_target)
		# Check if in range and attack conditions are met
		if can_attack_target(current_target):
			attack(current_target)
