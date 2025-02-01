extends Enemy

func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._melee_attack(target)
	animation_player.speed_scale = 5
	animation_player.play("2H_Melee_Attack_Chop")
