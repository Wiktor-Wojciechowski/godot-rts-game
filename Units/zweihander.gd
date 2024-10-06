extends Unit

class_name Zweihander

func attack(target):
	attack_component._rotate_to_target(target)
	$AnimationPlayer.play("RedTeam_SwordsMen_Armature|Atack_TwoHandSwordsMen")
	attack_component._melee_attack(target)
