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

@export var size = 2

func _ready() -> void:
	if unit_resource:
		attack_component.attack_damage = unit_resource.attack_damage
		attack_component.attack_cooldown = unit_resource.attack_speed
		attack_component.attack_range = unit_resource.attack_range
		movement_component.speed = unit_resource.movement_speed
		movement_component.stop_distance = unit_resource.attack_range - 0.5
		health_component.max_health = unit_resource.health
		health_component.health = unit_resource.health
		
		

func _process(delta):
	unit_behavior()

func can_attack_target(target) -> bool:
	if global_position.distance_to(target.global_position) > attack_component.attack_range + target.size:
		return false
	
	return attack_component.can_attack and not (movement_component.moving and not can_attack_while_moving)

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
		if can_attack_target(current_target):
			attack(current_target)
