extends Node3D

class_name Building

@export var building_resource: BuildingData

@export var team = 1

@export var size = 2

@onready var selection = $Selection
@onready var health_component = $HealthComponent

var menu = null

var building_name = "Building"

signal building_destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.collision_mask = 20
	health_component.death.connect(on_building_destroyed)
	health_component.max_health = building_resource.health
	health_component.health = building_resource.health
	building_name = building_resource.building_name
	

func on_building_destroyed(building):
	building_destroyed.emit(self)
