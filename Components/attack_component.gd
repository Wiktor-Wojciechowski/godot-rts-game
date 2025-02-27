extends Node3D

class_name AttackComponent

# Attack properties
@export var attack_damage: int = 20
@export var detection_range: float = 25.0
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0

@onready var attack_range_component = $AttackRange
@onready var bullet_spawner = $BulletSpawner

@export var bullet_scene: PackedScene = preload("res://Projectiles/bullet.tscn")

@onready var attacker = get_parent()
@onready var structures = get_tree().current_scene.find_child("Structures")

var can_attack = true
signal target_added
signal target_removed

# Cache for target nodes (enemies)
var target_nodes: Array = []
var target = null
var attack_timer: float = 0.0


func _ready() -> void:
	attack_range_component.get_node("CollisionShape3D").shape.radius = detection_range
	attack_range_component.show()

func _process(delta: float) -> void:
	# Update the attack cooldown timer
	if attack_timer > 0:
		attack_timer -= delta
	
	# Reset attack state when the timer reaches zero
	can_attack = attack_timer <= 0
	

# Helper function to rotate to target
func _rotate_to_target(target: Node) -> void:
	var target_pos = Vector3(target.position.x, get_parent().position.y, target.position.z)
	get_parent().look_at(target_pos, Vector3.UP)

func _on_attack_range_body_entered(body: Node3D) -> void:
	if body is Unit or body is Building or body is Enemy:
		target_nodes.append(body)
		target_added.emit()
		emit_signal("target_added")

func _on_attack_range_body_exited(body: Node3D) -> void:
	if body in target_nodes:
		target_nodes.erase(body)
		target_removed.emit()

func _shoot(current_target):
	can_attack = false
	
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
	bullet_instance.look_at(current_target.global_position)
	
	attack_timer = attack_cooldown
	
	var attack_sound: AudioStreamPlayer3D = get_parent().get_node_or_null("attack_sound")
	if attack_sound:
		attack_sound.play()

func _melee_attack(current_target):
	can_attack = false
	if current_target.health_component:
		current_target.health_component.take_damage(attack_damage)
	attack_timer = attack_cooldown
	
	var attack_sound: AudioStreamPlayer3D = get_parent().get_node_or_null("attack_sound")
	if attack_sound:
		attack_sound.play()

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
	#for enemy to get player buildings
	var buildings = structures.get_children()

	var closest_building = null
	var closest_distance = INF
	if not buildings.is_empty():
		for building in buildings:
			if building.team != attacker.team:
				var distance = global_position.distance_to(building.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_building = building
	return closest_building
