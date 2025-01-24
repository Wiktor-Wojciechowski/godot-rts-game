extends Control

@onready var unit_selector = get_tree().current_scene.get_node("UnitSelector")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is Building:
		$Panel/NameLabel.text = get_parent().building_name
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent() is Building:
		$Panel/HealthLabel.text = "Health: " + str(get_parent().health_component.health) + "/" + str(get_parent().health_component.max_health) 
	
func _on_panel_mouse_entered() -> void:
	print("sub entered")
	unit_selector.mouse_on_ui = true

func _on_panel_mouse_exited() -> void:
	print("sub exited")
	unit_selector.mouse_on_ui = false
