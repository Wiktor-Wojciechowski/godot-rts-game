extends Objective

class_name DefeatEnemiesObjective

@export var total_enemies_to_defeat: int = 0

func check_completion() -> bool:
	if game_manager:
		var enemies_defeated = game_manager.get_enemies_defeated
		is_completed = enemies_defeated >= total_enemies_to_defeat
	return is_completed
