extends Node3D

class_name Building

@export var team = 1

@onready var selection = $Selection
@onready var health_component = $HealthComponent

var menu = null

signal building_destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_component.death.connect(on_building_destroyed)

func on_building_destroyed():
	building_destroyed.emit()
