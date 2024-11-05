extends Enemy

func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)
	animation_player.speed_scale = 5
	animation_player.play("1H_Melee_Attack_Chop")
