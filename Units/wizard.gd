extends Unit

class_name Wizard
	
func attack(target):
	attack_component._rotate_to_target(target)
	attack_component._shoot(target)
