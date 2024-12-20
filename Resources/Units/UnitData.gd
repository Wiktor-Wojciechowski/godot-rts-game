# UnitData.gd
extends Resource
class_name UnitData

# Define the unit's properties
@export var unit_name: String
@export var production_time: float
@export var health: int
@export var attack: int
@export var movement_speed: float
@export var production_cost: Dictionary
