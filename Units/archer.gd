extends Unit

class_name Archer

func _ready() -> void:
	super._ready()
	attack_component.bullet_scene = preload("res://Projectiles/arrow.tscn")

func attack(target):
	attack_component._rotate_to_target(target)
	$AnimationPlayer.play("RedTeam_Archer_Armature|Atack_Archer")
	attack_component._shoot(target)
