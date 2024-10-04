extends Node3D

# Attack properties
@export var attack_damage: int = 20
@export var detection_range: float = 25.0
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
@export var can_attack_while_moving = false

@export var attack_animation_string: String

@onready var attack_range_component = $AttackRange
@onready var bullet_spawner = $BulletSpawner

@onready var attacker = get_parent()
@onready var structures = get_tree().current_scene.find_child("Structures")

var can_attack = true

# Cache for target nodes (enemies)
var target_nodes: Array = []
var target = null
var attack_timer: float = 0.0


func _ready() -> void:
	attack_range_component.get_node("CollisionShape3D").shape.radius = detection_range
	attack_range_component.show()

func _process(delta: float) -> void:
	# Update attack cooldown timer
	if attack_timer > 0:
		attack_timer -= delta
		can_attack = true

	if not target:
		target = _find_closest_enemy()

	if attack_timer > 0 or not can_attack or (attacker.movement_component.moving and not can_attack_while_moving):
		return

	if target and target.team != attacker.team:
		if attacker.global_position.distance_to(target.global_position) <= attack_range:
			_rotate_to_target(target)
			
			if get_parent().has_node("AnimationPlayer"):
				var ap = get_parent().get_node("AnimationPlayer")
				ap.play(attack_animation_string)
			
			_shoot(target)
			attack_timer = attack_cooldown

# Helper function to rotate to target
func _rotate_to_target(target: Node) -> void:
	var target_pos = Vector3(target.position.x, get_parent().position.y, target.position.z)
	get_parent().look_at(target_pos, Vector3.UP)


func _on_attack_range_body_entered(body: Node3D) -> void:
		target_nodes.append(body)

func _on_attack_range_body_exited(body: Node3D) -> void:
	if body in target_nodes:
		target_nodes.erase(body)

func _shoot(current_target):
	can_attack = false
	var bullet_scene: PackedScene = preload("res://Projectiles/Bullet.tscn")
	var bullet_instance = bullet_scene.instantiate()
	
	bullet_instance.team = get_parent().team
	
	get_tree().current_scene.add_child(bullet_instance)
	
	# Set bullet's initial position at the sentry's location
	bullet_instance.global_transform.origin = $BulletSpawner.global_transform.origin
	bullet_instance.damage = attack_damage
	# Calculate the direction from the sentry to the target
	var bullet_direction = (current_target.global_transform.origin - $BulletSpawner.global_transform.origin).normalized()

	# Set the bullet's direction
	bullet_instance.set_direction(bullet_direction)

func _find_closest_enemy() -> Node3D:
	var closest_enemy = null
	var closest_distance = INF
	for enemy in target_nodes:
		var distance = attacker.global_transform.origin.distance_to(enemy.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy
	
func _find_closest_building():
	var player_buildings = structures.get_children()

	var closest_building = null
	var closest_distance = INF
	if not player_buildings.is_empty():
		for building in player_buildings:
			if building.team != attacker.team:
				var distance = global_position.distance_to(building.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_building = building
	return closest_building
