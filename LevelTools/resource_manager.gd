extends Node

# Define the different resources
@export var wood: int = 0
@export var stone: int = 0
@export var food: int = 0
@export var gold: int = 0

# Signal to update the UI when resources change
signal resources_updated()

# Add resources based on type
func add_resource(resource_type: String, amount: int) -> void:
	match resource_type:
		"wood":
			wood += amount
		"stone":
			stone += amount
		"food":
			food += amount
		"gold":
			gold += amount

	# Emit signal to update UI
	emit_signal("resources_updated")

# Get the current amount of a specific resource
func get_resource(resource_type: String) -> int:
	match resource_type:
		"wood":
			return wood
		"stone":
			return stone
		"food":
			return food
		"gold":
			return gold
		_:
			return 0
