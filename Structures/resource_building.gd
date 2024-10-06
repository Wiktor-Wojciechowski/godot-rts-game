extends Building

class_name ResourceBuilding

var resource_manager

@export var resource_type: String = ""
@export var generated_amount: int = 5
@export var generation_interval: float = 3.0

var resource_timer: Timer

func _ready() -> void:
	resource_manager = get_tree().current_scene.find_child("ResourceManager")
	# Create a Timer node if not already present in the scene
	resource_timer = Timer.new()
	resource_timer.wait_time = generation_interval
	resource_timer.one_shot = false
	resource_timer.autostart = true
	add_child(resource_timer)

	# Connect the timeout signal to the resource generation function
	resource_timer.timeout.connect(generate_resources)

func generate_resources() -> void:
	# Call the ResourceManager to add resources
	#print(resource_type, generated_amount)
	resource_manager.add_resource(resource_type, generated_amount)
