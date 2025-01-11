extends Objective

class_name DestroyEnemyHQObjective

@export var number_of_hqs_to_destroy = 1

func check_completion():
	print("checking completion")
	if game_manager:
		if game_manager.enemy_hqs_destroyed >= number_of_hqs_to_destroy:
			completed = true
			return true
	return false
