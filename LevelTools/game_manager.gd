extends Node3D

class_name GameManager

var number_of_units = 0
var number_of_enemies = 0

var units_node
var enemies_node

@onready var unit_number_label = $Label1
@onready var enemy_number_label = $Label2

var enemies_defeated = 0
var units_lost = 0
var destroyed_enemy_buildings = 0

var special_enemies_defeated = 0
var waves_completed = 0
var current_wave_killcount = 0
var enemy_hqs_destroyed = 0

var built_structures = []

@export var level_objectives: Array[Objective] = []

var objectives_completed = 0

var producible_units: Array[PackedScene] = [
	preload("res://Units/archer.tscn"),
	preload("res://Units/soldier.tscn"),
	preload("res://Units/wizard.tscn"),
	preload("res://Units/zweihander.tscn")
]

@export var max_population = 10
var current_population = 0

@onready var objective_menu = get_parent().get_node("UI").get_node("ObjectiveMenu")

var is_level_failed = false
@export var can_lose_when_population_0 = false
@export var has_to_complete_waves = false
@export var can_lose_when_hq_destroyed = false

signal all_objectives_completed
signal level_failed
signal population_changed
signal enemy_hq_destroyed
signal special_enemy_defeated
signal wave_completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for objective in level_objectives:
		objective.set_game_manager(self)
		#add a label
	update_objectives_menu()
	
	units_node = get_tree().current_scene.find_child("Units")
	for unit in units_node.get_children():
		unit.get_node("HealthComponent").death.connect(_on_unit_death)
		increase_current_population(1)
	
	enemies_node = get_tree().current_scene.find_child("Enemies")
	
	_process_existing_enemies()
	
	get_tree().node_added.connect(_on_node_added)
	
	level_failed.connect(on_level_failed)
	population_changed.connect(on_population_changed)
	
	var hq = get_parent().find_child("PlayerHeadQuarters")
	if hq:
		hq.building_destroyed.connect(on_hq_destroyed)
		
	wave_completed.connect(on_wave_completed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	number_of_units = units_node.get_children().size()
	unit_number_label.text = str("Units: ",number_of_units)
	number_of_enemies = enemies_node.get_children().size()
	enemy_number_label.text = str("Enemies: ",number_of_enemies)
	

func check_objectives():
	if is_level_failed:
		return
		
	for objective in level_objectives:
		if not objective.completed:
			if objective.check_completion():
				objectives_completed += 1
			
	update_objectives_menu()
	if objectives_completed == level_objectives.size():
		emit_signal("all_objectives_completed")
		get_parent().get_node("UI").get_node("LevelCompleteScreen").show()
		#show_completion_message()

func _process_existing_enemies() -> void:
	#var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies_node.get_children():
		_connect_enemy(enemy)

func _connect_enemy(enemy: Enemy) -> void:
	var hc = enemy.get_node("HealthComponent")
	hc.death.connect(_on_enemy_death)

func _connect_unit(unit: Unit) -> void:
	var hc = unit.get_node('HealthComponent')
	hc.death.connect(_on_unit_death)

func _connect_enemy_building(building: Unit) -> void:
	var hc = building.get_node('HealthComponent')
	hc.death.connect(_on_enemy_building_destroyed)

func _on_node_added(node: Node) -> void:
	if node is Enemy:
		number_of_enemies += 1
		_connect_enemy(node)
	
	if node is Unit:
		number_of_units += 1
		_connect_unit(node)
	
	if node is Building:
		if node.team == 2:
			_connect_enemy_building(node)
			

func _on_enemy_death(enemy: Enemy) -> void:
	number_of_enemies -= 1
	enemies_defeated += 1
	
	if has_to_complete_waves:
		current_wave_killcount += 1
	
	if enemy.has_node("SpecialEnemyComponent"):
		special_enemies_defeated += 1
	
	check_objectives()
	
func _on_unit_death(unit: Unit):
	number_of_units -= 1
	units_lost += 1
	decrease_current_population(1)
	check_objectives()
	
func _on_enemy_building_destroyed(building):
	destroyed_enemy_buildings +=1
	check_objectives()
	
#func has_built_structure(structure_name: String) -> bool:
	#return structure_name in built_structures
	#
#func add_built_structure(structure_name: String) -> void:
	#if structure_name not in built_structures:
		#built_structures.append(structure_name)
		#print("Structure built: ", structure_name)
		#check_objectives()
		
func update_objectives_menu() -> void:
	objective_menu.clear_objectives()
	for objective in level_objectives:
		objective_menu.add_objective(objective)

func on_hq_destroyed():
	if can_lose_when_hq_destroyed:
		level_failed.emit()
	
func on_level_failed():
	is_level_failed = true
	get_parent().get_node("UI").get_node("LevelFailedScreen").show()
	print('level failed')
	
func increase_current_population(amount):
	current_population += amount
	get_parent().get_node("UI").get_node("PopulationLabel").text = "Population: %s/%s" % [str(current_population), str(max_population)]
	emit_signal("population_changed")

func decrease_current_population(amount):
	current_population -= amount
	get_parent().get_node("UI").get_node("PopulationLabel").text = "Population: %s/%s" % [str(current_population), str(max_population)]
	emit_signal("population_changed")

func on_population_changed():
	if current_population <= 0 and can_lose_when_population_0:
		level_failed.emit()

func on_wave_completed():
	print("wave complete")
	current_wave_killcount = 0
	waves_completed += 1

func add_new_objective(objective: Objective):
	level_objectives.append(objective)
	update_objectives_menu()
