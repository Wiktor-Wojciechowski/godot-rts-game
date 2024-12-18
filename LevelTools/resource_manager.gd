extends Node

class_name ResourceManager

# Define the resources in a dictionary
@export var resources: Dictionary = {
	"wood": 0,
	"stone": 0,
	"food": 0,
	"gold": 0
}

# Signal to update the UI when resources change
signal resources_updated

# Add or subtract a resource based on type
func add_resource(resource_type: String, amount: int) -> void:
	resource_type = resource_type.to_lower()
	if resources.has(resource_type):
		resources[resource_type] += amount
		emit_signal("resources_updated")
	else:
		print("Resource type not recognized: ", resource_type)

func substract_resource(resource_type: String, amount: int) -> void:
	if resources.has(resource_type):
		resources[resource_type] -= amount
		emit_signal("resources_updated")
	else:
		print("Resource type not recognized: ", resource_type)

# Add or subtract multiple resources at once
func add_resources(resources: Dictionary) -> void:
	for resource_type in resources.keys():
		add_resource(resource_type, resources[resource_type])

func substract_resources(resources):
	for resource_type in resources.keys():
		substract_resource(resource_type, resources[resource_type])	

# Get the current amount of a specific resource
func get_resource(resource_type: String) -> int:
	if resources.has(resource_type):
		return resources[resource_type]
	else:
		print("Resource type not recognized: ", resource_type)
		return 0
