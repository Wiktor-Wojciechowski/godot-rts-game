extends Objective

class_name DefeatEnemiesObjective

@export var total_enemies_to_defeat: int = 1

# Check if the objective is completed
func check_completion() -> bool:
	if game_manager:
		progress = (float(game_manager.enemies_defeated) / total_enemies_to_defeat) * 100
		if game_manager.enemies_defeated >= total_enemies_to_defeat:
			completed = true
			return true
	return false
