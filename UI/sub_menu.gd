extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is Building:
		$Panel/NameLabel.text = get_parent().building_name
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent() is Building:
		$Panel/HealthLabel.text = "Health: " + str(get_parent().health_component.health) + "/" + str(get_parent().health_component.max_health) 
	
