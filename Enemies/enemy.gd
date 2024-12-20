extends CharacterBody3D

class_name Enemy

@onready var movement_component = $MovementComponent
@onready var attack_component = $AttackComponent
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent  
@onready var animation_player = find_child("AnimationPlayer")

@export var can_attack_while_moving = true

var enemies_in_range = []

var player_buildings = []
var closest_building = null
@export var seeks_out_buildings = false

var current_target = null

var team = 2

enum Command { NONE, HOLD_POSITION, MOVE_TO_POSITION, ATTACK_TARGET }
var current_command = Command.NONE

func _ready() -> void:
	#movement_component.move_to(Vector3(-200,0,0))
	pass
	
func _process(delta: float) -> void:
	enemy_behavior()


func enemy_behavior():
	enemies_in_range = attack_component.target_nodes
	
	if not enemies_in_range.is_empty():
		var closest_enemy = attack_component._find_closest_enemy()
		if closest_enemy:
			current_target = closest_enemy
	else:
		if not closest_building and seeks_out_buildings:
			closest_building = attack_component._find_closest_building()
		else:
			current_target = closest_building
			
	if current_target:
		if not is_instance_valid(current_target) or current_target.team == team:
			current_target = null
			return
		
		movement_component.follow_target(current_target)
		# Check if in range and attack conditions are met
		if can_attack_target(current_target):
			attack(current_target)

func can_attack_target(target) -> bool:
	if global_position.distance_to(target.global_position) > attack_component.attack_range:
		return false
	
	# Ensure attack timer and other conditions are met
	return attack_component.can_attack and not (movement_component.moving and can_attack_while_moving)

func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)
