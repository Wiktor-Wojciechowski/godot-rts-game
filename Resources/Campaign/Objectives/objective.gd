extends Resource

class_name Objective

@export var objective_name: String = "Objective"
@export var description: String = "Objective description"
@export var is_completed:bool = false

var game_manager

func check_completion() -> bool:
	#completion logic
	return is_completed

func complete() -> void:
	is_completed = true
