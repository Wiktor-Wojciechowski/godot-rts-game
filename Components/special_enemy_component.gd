extends Node3D

class_name SpecialEnemyComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemy = get_parent()
	enemy.ready.connect(on_enemy_ready)

func on_enemy_ready():
	var enemy = get_parent()
	enemy.scale *= Vector3(1.5, 1.5, 1.5)
	enemy.get_node("HealthComponent").max_health *= 5
	enemy.get_node("HealthComponent").health *= 5
	enemy.get_node("MovementComponent").speed *= 0.75
