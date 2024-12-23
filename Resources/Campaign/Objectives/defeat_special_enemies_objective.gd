extends Objective

class_name DefeatEnemiesObjective

@export var total__special_enemies_to_defeat: int = 0

# Check if the objective is completed
func check_completion() -> bool:
	if game_manager:
		if game_manager.special_enemies_defeated >= total__special_enemies_to_defeat:
			completed = true
			return true
	return false
