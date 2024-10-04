extends Control

@onready var wood_label = $WoodLabel
@onready var stone_label = $StoneLabel
@onready var food_label = $FoodLabel
@onready var gold_label = $GoldLabel

func _ready() -> void:
	# Connect the signal from the resource manager to update UI
	ResourceManager.resources_updated.connect(_update_resource_ui)
	_update_resource_ui() # Initial update

func _update_resource_ui() -> void:
	wood_label.text = "Wood: %d" % ResourceManager.get_resource("wood")
	stone_label.text = "Stone: %d" % ResourceManager.get_resource("stone")
	food_label.text = "Food: %d" % ResourceManager.get_resource("food")
	gold_label.text = "Gold: %d" % ResourceManager.get_resource("gold")
