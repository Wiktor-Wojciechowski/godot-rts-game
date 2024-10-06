extends Control

@export var resource_manager: Node3D

@onready var wood_label = $WoodLabel
@onready var stone_label = $StoneLabel
@onready var food_label = $FoodLabel
@onready var gold_label = $GoldLabel

func _ready() -> void:
	# Connect the signal from the resource manager to update UI
	resource_manager.resources_updated.connect(_update_resource_ui)
	_update_resource_ui() # Initial update

func _update_resource_ui() -> void:
	wood_label.text = "Wood: %d" % resource_manager.get_resource("wood")
	stone_label.text = "Stone: %d" % resource_manager.get_resource("stone")
	food_label.text = "Food: %d" % resource_manager.get_resource("food")
	gold_label.text = "Gold: %d" % resource_manager.get_resource("gold")
