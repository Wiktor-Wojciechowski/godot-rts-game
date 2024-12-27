extends Node3D

class_name SpecialEnemyComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemy = get_parent()
	enemy.scale *= Vector3(1.5, 1.5, 1.5)
	enemy.get_node("HealthComponent").max_health *= 2
	enemy.get_node("HealthComponent").health *= 2
	enemy.get_node("MovementComponent").speed *= 0.75


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
