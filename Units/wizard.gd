extends Unit

class_name Wizard

func _ready() -> void:
	super._ready()
	attack_component.bullet_scene = preload("res://Projectiles/magic_ball.tscn")
	
func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)
