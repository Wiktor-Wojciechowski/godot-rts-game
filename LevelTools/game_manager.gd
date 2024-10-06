extends Node3D

var number_of_units = 0
var number_of_enemies = 0

var units_node
var enemies_node

@onready var unit_number_label = $Label1
@onready var enemy_number_label = $Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	units_node = get_tree().current_scene.find_child("Units")
	enemies_node = get_tree().current_scene.find_child("Enemies")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	number_of_units = units_node.get_children().size()
	unit_number_label.text = str("Units: ",number_of_units)
	number_of_enemies = enemies_node.get_children().size()
	enemy_number_label.text = str("Enemies: ",number_of_enemies)
