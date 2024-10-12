extends Node

class_name HealthComponent

@export var max_health: int = 10

var health = null

var is_dead = false #necessary to avoid triggering die() multiple times

signal health_changed
signal death

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func take_damage(damage):
	health -= damage
	health_changed.emit()
	if health <= 0 and not is_dead:
		is_dead = true
		die()
		
func die():
	if get_parent() is Building:
		get_parent().on_building_destroyed
	
	death.emit()
	get_parent().queue_free()
