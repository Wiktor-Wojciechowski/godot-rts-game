extends Objective

class_name SurviveWavesObjective

@export var waves_to_complete: int = 1

func check_completion():
	if game_manager:
		if game_manager.waves_completed == waves_to_complete:
			completed = true
			return true
	return false
