extends Building

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
	
	selection.selected.connect(on_selected)
	selection.deselected.connect(on_deselected)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_selected():
	$ProductionQueue.show()

func on_deselected():
	$ProductionQueue.hide()
