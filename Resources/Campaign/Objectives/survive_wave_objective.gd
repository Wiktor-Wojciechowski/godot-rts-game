extends Objective

class_name SurviveWaveObjective

@export var enemies_to_defeat = 0

func check_completion():
	print("checking wave obj")
	if game_manager:
		print("killcount: ", game_manager.current_wave_killcount)
		print("enemies_to_defeat: ", enemies_to_defeat)
		if game_manager.current_wave_killcount >= enemies_to_defeat:
			game_manager.wave_completed.emit()
			completed = true
			return true
	return false
