extends Node

# A queue to hold units, where each unit has a name and production time
var unit_queue = []
var current_unit = null
var production_timer: Timer
var producible_units: Array[PackedScene]

@onready var units = get_tree().current_scene.find_child("Units")
@onready var resource_manager = get_tree().current_scene.find_child("ResourceManager")
@onready var game_manager = get_tree().current_scene.find_child("GameManager")

# UI nodes for displaying queue and production progress
@onready var queue_display: Label = $BackgroundPanel/ScrollContainer/QueueDisplay
@onready var production_progress_bar: ProgressBar = $BackgroundPanel/ProductionProgressBar

func _ready():
	# Create the timer, no need to set wait time immediately
	production_timer = Timer.new()
	production_timer.one_shot = true
	production_timer.connect("timeout", Callable(self, "_on_production_complete"))
	add_child(production_timer)
	game_manager.population_changed.connect(on_population_changed)
	
	# Initial UI update
	update_queue_display()

# Function to add a unit to the queue
func add_unit_to_queue(index:int, unit_name: String, unit_production_time: float) -> void:
	var unit = {
		"index": index,
		"name": unit_name,
		"production_time": unit_production_time,
	}
	unit_queue.append(unit)
	
	# If no unit is being produced, start producing the new one
	if not production_timer.is_processing():
		start_production()

	# Update the queue display
	update_queue_display()

# Start producing the first unit in the queue
func start_production() -> void:
	if unit_queue.size() > 0:
		current_unit = unit_queue[0]

		production_timer.wait_time = current_unit["production_time"]
		production_timer.start()
		production_progress_bar.max_value = current_unit["production_time"]
		production_progress_bar.value = 0

		# Update the queue display to reflect that a unit is being produced
		update_queue_display()
		# Start updating the progress bar every frame
		set_process(true)

# Update the progress bar every frame
func _process(delta: float) -> void:
	if production_timer.is_processing() and current_unit != null:
		production_progress_bar.value += delta

# When production is complete, remove the unit from the queue
func _on_production_complete() -> void:
	if unit_queue.size() > 0:
		unit_queue.pop_front() # Remove the completed unit
		var completed_unit = producible_units[current_unit["index"]].instantiate()
		completed_unit.position = Vector3(0,-1000, 0)
		units.add_child(completed_unit)
		completed_unit.global_position = get_parent().spawn_point.global_position
		current_unit = null
		
		game_manager.increase_current_population(1)

		# Stop updating the progress bar
		production_progress_bar.value = 0
		set_process(false)

		# Start producing the next unit, if any
		if unit_queue.size() > 0:
			start_production()
	
	update_queue_display()

# Function to update the queue display in the UI
func update_queue_display() -> void:
	var queue_text = "Production Queue:\n"
	for i in range(unit_queue.size()):
		var unit = unit_queue[i]
		queue_text += str(i + 1) + ". " + unit["name"] + " (" + str(unit["production_time"]) + "s)\n"
	
	if current_unit != null:
		queue_text += "\nProducing: " + current_unit["name"]
	
	queue_display.text = queue_text

func on_population_changed():
	if game_manager.current_population >= game_manager.max_population:
		production_timer.paused = true
	else:
		production_timer.paused = false
		
