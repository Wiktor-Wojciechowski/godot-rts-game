extends CharacterBody3D

class_name Enemy

@onready var movement_component = $MovementComponent
@onready var attack_component = $AttackComponent
@onready var health_bar = $HealthBar
@onready var health_component = $HealthComponent  

var enemies_in_range = []

var player_buildings = []
var closest_building = null

var team = 2

var speed = 1

func _ready() -> void:
	#movement_component.move_to(Vector3(-200,0,0))
	pass
	
func _process(delta: float) -> void:
	enemy_behavior()


func enemy_behavior():
	enemies_in_range = attack_component.target_nodes
	
	# Move to the closest enemy if one is in range
	if not enemies_in_range.is_empty():
		var closest_enemy = attack_component._find_closest_enemy()
		if closest_enemy:
			attack_component.target = closest_enemy
			movement_component.follow_target(closest_enemy)
			return
	
	# Otherwise, move to the closest building
	if not closest_building:
		closest_building = attack_component._find_closest_building()
	else:
		attack_component.target = closest_building
		movement_component.follow_target(closest_building)
