extends Objective

class_name DestroyEnemyHQObjective

func check_completion():
	if game_manager:
		if game_manager.enemy_hqs_destroyed >= 0:
			completed = true
			return true
	return false
