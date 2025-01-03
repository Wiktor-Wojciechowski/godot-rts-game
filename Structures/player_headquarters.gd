extends Building

class_name HeadQuarters

var current_model: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Model.hide()
	super._ready()
	match team:
		1: current_model  = preload("res://Assets/BuildingModels/building_castle_red.fbx").instantiate()
		2: current_model  = preload("res://Assets/BuildingModels/building_castle_blue.fbx").instantiate()
	
	current_model.scale = Vector3(3,3,3)
	add_child(current_model)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
