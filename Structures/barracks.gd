extends Building

class_name Barracks

@onready var spawn_point = $SpawnPoint
@onready var production_queue = $ProductionQueue

var producible_units: Array[PackedScene]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	menu = preload("res://UI/barracks_menu.tscn")
	producible_units = get_tree().current_scene.find_child("GameManager").producible_units
	production_queue.producible_units = producible_units
	production_queue.hide()
	

func on_selected():
	$ProductionQueue.show()

func on_deselected():
	$ProductionQueue.hide()
