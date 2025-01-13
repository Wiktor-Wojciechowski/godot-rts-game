extends Objective

class_name DestroyEnemyHQObjective

@export var number_of_hqs_to_destroy = 1

func check_completion():
	if game_manager:
		progress = (game_manager.enemy_hqs_destroyed / number_of_hqs_to_destroy) * 100
		if game_manager.enemy_hqs_destroyed >= number_of_hqs_to_destroy:
			completed = true
			return true
	return false
