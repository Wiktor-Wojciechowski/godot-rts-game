extends Node3D

class_name Building

@export var building_resource: BuildingData

@export var team = 1

@export var size = 2

@onready var selection = $Selection
@onready var health_component = $HealthComponent

var menu = preload("res://UI/sub_menu.tscn")
var sub_menu = null

var building_name = "Building"

signal building_destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.collision_mask = 20
	health_component.death.connect(on_building_destroyed)
	health_component.max_health = building_resource.health
	health_component.health = building_resource.health
	building_name = building_resource.building_name
	size = building_resource.size
	
	sub_menu = menu.instantiate()
	add_child(sub_menu)
	sub_menu.hide()
	
	sub_menu.get_node("Panel/SellButton").pressed.connect(on_sell_button_pressed)
	
	if not selection.selected.is_connected(on_selected):
		selection.selected.connect(on_selected)
	if not selection.deselected.is_connected(on_deselected):
		selection.deselected.connect(on_deselected)

func on_building_destroyed(building):
	building_destroyed.emit(self)

func on_selected():
	sub_menu.show()
	
func on_deselected():
	sub_menu.hide()

func on_sell_button_pressed():
	print("selling")
	building_destroyed.emit(self)
	queue_free()
