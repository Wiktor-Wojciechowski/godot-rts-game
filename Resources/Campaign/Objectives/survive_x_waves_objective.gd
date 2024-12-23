extends Objective

class_name SurviveWavesObjective

@export var waves_to_survive: int = 1

func check_completion():
	if game_manager:
		if game_manager.waves_survived == waves_to_survive:
			completed = true
			return true
	return false
