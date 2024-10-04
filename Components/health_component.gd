extends Node

class_name HealthComponent

@export var max_health: int = 10

var health = null

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
	if health <= 0:
		die()
		
func die():
	death.emit()
	get_parent().queue_free()
