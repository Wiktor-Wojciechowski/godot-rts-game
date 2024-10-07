extends Building

@onready var spawn_point = $SpawnPoint
@onready var production_queue = $ProductionQueue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu = preload("res://UI/barracks_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
