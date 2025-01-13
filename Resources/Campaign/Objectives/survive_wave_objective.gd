extends Objective

class_name SurviveWaveObjective

@export var enemies_to_defeat = 1

func check_completion():
	if game_manager and not completed:
		progress = (float(game_manager.current_wave_killcount) / float(enemies_to_defeat)) * 100
		if game_manager.current_wave_killcount >= enemies_to_defeat:
			completed = true
			game_manager.current_wave_killcount = 0
			game_manager.wave_completed.emit()
			return true
	return false
