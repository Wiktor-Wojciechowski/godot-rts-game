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

var built_structures = []

var fake_objectives = [
	{
		'name': 'Kill 2 enemies',
		'type': 'defeat_enemies',
		'target': 2,
		'completed': false,
	}
]

@export var level_objectives: Array[Objective] = []

var objectives_completed = 0

var producible_units: Array[PackedScene] = [
	preload("res://Units/archer.tscn"),
	preload("res://Units/soldier.tscn"),
	preload("res://Units/wizard.tscn"),
	preload("res://Units/zweihander.tscn")
]

@onready var objective_menu = get_parent().get_node("UI").get_node("ObjectiveMenu")

signal all_objectives_completed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for objective in level_objectives:
		print(objective.objective_name)
		objective.set_game_manager(self)
		#add a label
	update_objectives_menu()
	
	units_node = get_tree().current_scene.find_child("Units")
	enemies_node = get_tree().current_scene.find_child("Enemies")
	
	print(enemies_node.get_children())
	_process_existing_enemies()
	
	get_tree().node_added.connect(_on_node_added)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	number_of_units = units_node.get_children().size()
	unit_number_label.text = str("Units: ",number_of_units)
	number_of_enemies = enemies_node.get_children().size()
	enemy_number_label.text = str("Enemies: ",number_of_enemies)
	

func check_objectives():
	for objective in level_objectives:
		if not objective.completed:
			if objective.check_completion():
				print('Objective ', objective.objective_name,' completed')
				objectives_completed += 1
			#print("Objective not yet completed: ", objective.objective_name)
			
	update_objectives_menu()
	if objectives_completed == level_objectives.size():
		emit_signal("all_objectives_completed")
		print("All objectives completed!")
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
	#print("Enemy defeated: ", enemy.name)
	number_of_enemies -= 1
	enemies_defeated += 1
	check_objectives()
	
func _on_unit_death(unit: Unit):
	number_of_units -= 1
	units_lost += 1
	check_objectives()
	
func _on_enemy_building_destroyed(building):
	print('Building destroyed')
	destroyed_enemy_buildings +=1
	#check_objectives()
	
func has_built_structure(structure_name: String) -> bool:
	return structure_name in built_structures
	
func add_built_structure(structure_name: String) -> void:
	if structure_name not in built_structures:
		built_structures.append(structure_name)
		print("Structure built: ", structure_name)
		#check_objectives()
		
func update_objectives_menu() -> void:
	objective_menu.clear_objectives()
	for objective in level_objectives:
		objective_menu.add_objective(objective)
