extends CharacterBody3D

class_name Enemy

@export var enemy_resource: EnemyData

@onready var movement_component = $MovementComponent
@onready var attack_component = $AttackComponent
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent  
@onready var animation_player = find_child("AnimationPlayer")

@export var can_attack_while_moving = true

var enemies_in_range = []

var closest_building = null
@export var seeks_out_buildings = false
var current_target = null
var team = 2
@export var size = 2

func _ready() -> void:
	if enemy_resource:
		attack_component.attack_damage = enemy_resource.attack_damage
		attack_component.attack_cooldown = enemy_resource.attack_speed
		attack_component.attack_range = enemy_resource.attack_range
		movement_component.speed = enemy_resource.movement_speed
		movement_component.stop_distance = enemy_resource.attack_range - 0.5
		health_component.max_health = enemy_resource.health
		health_component.health = enemy_resource.health
		
	attack_component.target_added.connect(_on_attack_component_target_added)
	attack_component.target_removed.connect(_on_attack_component_target_removed)
	enemy_behavior()
	
func _process(delta: float) -> void:
	if(current_target):
		movement_component.follow_target(current_target)
		# Check if in range and attack conditions are met
		if can_attack_target(current_target):
			print("attacking ", current_target)
			attack(current_target)

func enemy_behavior():
	enemies_in_range = []
	for building in attack_component.target_nodes:
		if building.team != team:
			enemies_in_range.append(building)
	
	if not enemies_in_range.is_empty():
		var closest_enemy = attack_component._find_closest_enemy()
		if closest_enemy:
			current_target = closest_enemy
	else:
		if closest_building == null and seeks_out_buildings:
			closest_building = attack_component._find_closest_building()
		else:
			current_target = closest_building
			
	if current_target:
		if not is_instance_valid(current_target) or current_target.team == team:
			current_target = null
			return
		

func can_attack_target(target) -> bool:
	if not is_instance_valid(target):
		return false
	if target is Bullet:
		return false
	if target:
		if global_position.distance_to(target.global_position) > attack_component.attack_range + target.size:
			return false
	
	# Ensure attack timer and other conditions are met
	return attack_component.can_attack and not (movement_component.moving and can_attack_while_moving)

func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)


func _on_attack_component_target_added() -> void:
	enemy_behavior()
	pass # Replace with function body.


func _on_attack_component_target_removed() -> void:
	enemy_behavior()
	pass # Replace with function body.
