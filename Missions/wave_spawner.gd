extends Node3D

@export var waves = [
	{
		"spawn_timer": 60,
		"enemies": [
			{"type": "skeleton_minion", "count": 16},
			{"type": "skeleton_rogue", "count": 10}
		]
	},
		{
		"spawn_timer": 60,
		"enemies": [
			{"type": "skeleton_minion", "count": 10},
			{"type": "skeleton_rogue", "count": 10},
			{"type": "skeleton_warrior", "count": 10}
		]
	},
	{
		"spawn_timer": 60,
		"enemies": [
			{"type": "skeleton_warrior", "count": 10},
			{"type": "skeleton_warrior", "count": 10},
			{"type": "skeleton_wizard", "count": 6}
		]
	}
]

var available_enemies = {
	"skeleton_minion": preload("res://Enemies/skeleton_minion.tscn"),
	"skeleton_rogue": preload("res://Enemies/skeleton_rogue.tscn"),
	"skeleton_warrior": preload("res://Enemies/skeleton_warrior.tscn"),
	"skeleton_wizard": preload("res://Enemies/skeleton_wizard.tscn")
}

var next_wave_index = 0
var game_manager
var spawn_centers = []
var spawn_points = []
var enemy_size = 1.2

signal wave_spawned
signal all_waves_completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_tree().current_scene.get_node("GameManager")
	$WaveTimer.timeout.connect(on_wave_timer_timeout)
	wave_spawned.connect(on_wave_spawned)
	
	spawn_centers = $SpawnCenters.get_children()
	
	if waves.size() > 0:
		$WaveTimer.wait_time = waves[0].spawn_timer
	$WaveTimer.start()

func _process(delta: float) -> void:
	$TimeUntilNextWave.text = "Next Wave: " + str(round($WaveTimer.time_left))

func on_wave_timer_timeout():
	spawn_wave(waves[next_wave_index])
	
func spawn_wave(wave):	
	var total_enemies_in_wave = 0
	for enemies in wave.enemies:
		total_enemies_in_wave += enemies.count
	
	var new_objective = SurviveWaveObjective.new()
	new_objective.game_manager = get_tree().current_scene.find_child("GameManager")
	new_objective.enemies_to_defeat = total_enemies_in_wave
	new_objective.objective_name = "Survive Wave " + str(next_wave_index + 1)
	new_objective.description = "Defeat " + str(total_enemies_in_wave) + " Enemies"
	game_manager.add_new_objective(new_objective)
	
	calculate_box_positions(spawn_centers[next_wave_index].position, total_enemies_in_wave)
	
	var position_index = 0
	
	for enemies in wave.enemies:
		for i in range(enemies.count):
			if position_index < spawn_points.size():
				spawn_enemy(enemies.type, spawn_points[position_index])
				position_index += 1
				
	wave_spawned.emit()

func on_wave_spawned():
	next_wave_index += 1 
	if next_wave_index < waves.size():
		$WaveTimer.wait_time = waves[next_wave_index].spawn_timer
		$WaveTimer.start() 
	else:
		$WaveTimer.stop()
		all_waves_completed.emit()

func spawn_enemies(enemies):
	for i in enemies.count:
		spawn_enemy(enemies.type, spawn_points[i])

func spawn_enemy(enemy_type, pos):
	var enemies_node = get_tree().current_scene.find_child("Enemies")
	var enemy = available_enemies[enemy_type].instantiate()
	enemy.seeks_out_buildings = true
	enemies_node.add_child(enemy)
	enemy.position = pos

func calculate_box_positions(target_position: Vector3, enemy_count):
	spawn_points.clear()
	
	var num_units = enemy_count
	var row_length = ceil(sqrt(num_units))
	var column_length = ceil(num_units / row_length)

	if row_length * (column_length - 1) >= num_units:
		column_length -= 1

	var half_width = (row_length - 1) * enemy_size / 2
	var half_height = (column_length - 1) * enemy_size / 2

	for i in range(num_units):
		var row = i / int(row_length)
		var col = i % int(row_length)

		var position_x = target_position.x - half_width + col * enemy_size
		var position_z = target_position.z - half_height + row * enemy_size
		var new_position = Vector3(position_x, target_position.y, position_z)

		spawn_points.append(new_position)
