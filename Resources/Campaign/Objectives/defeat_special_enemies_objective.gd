extends Objective

class_name DefeatSpecialEnemiesObjective

@export var total_special_enemies_to_defeat: int = 0

# Check if the objective is completed
func check_completion() -> bool:
	if game_manager:
		if game_manager.special_enemies_defeated >= total_special_enemies_to_defeat:
			completed = true
			return true
	return false
