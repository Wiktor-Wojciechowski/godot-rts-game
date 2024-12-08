extends Objective

class_name DefeatEnemiesObjective

@export var total_enemies_to_defeat: int = 0

# Check if the objective is completed
func check_completion() -> bool:
	if game_manager:
		return game_manager.enemies_defeated >= total_enemies_to_defeat
	return false

# Indicate that this objective supports progress tracking
func can_track_progress() -> bool:
	return true

# Update progress (e.g., for UI or logs)
func update_progress() -> void:
	if game_manager:
		var current = game_manager.enemies_defeated
		print("Defeated ", current, " / ", total_enemies_to_defeat, " enemies")
