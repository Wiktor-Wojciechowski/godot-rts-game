extends Resource

class_name Objective

@export var objective_name: String = "Objective"
@export var description: String  = "Objective description"
@export var completed: bool = false

var game_manager: GameManager = null  # Reference to the GameManager

# Sets the game manager reference
func set_game_manager(manager: Node) -> void:
	game_manager = manager

# Override in subclasses to define completion logic
func check_completion() -> bool:
	return false

# Indicates if the objective can track progress (optional)
func can_track_progress() -> bool:
	return false

# Override to define progress-tracking logic
func update_progress() -> void:
	pass
