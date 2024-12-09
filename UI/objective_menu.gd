extends Control

@onready var close_button = $CloseButton
@onready var objective_list = $ObjectiveContainer

signal menu_closed  # Signal emitted when the menu is closed

# Called when the menu is ready
func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

# Handles closing the menu
func _on_close_button_pressed() -> void:
	objective_list.visible = !objective_list.visible
	emit_signal("menu_closed")

# Adds an objective to the menu
func add_objective(objective) -> void:
	var objective_panel = preload("res://UI/objective_panel.tscn").instantiate()
	objective_panel.set_objective(objective)
	$ObjectiveContainer/ScrollContainer/VBoxContainer.add_child(objective_panel)

# Clears all objectives from the menu
func clear_objectives() -> void:
	var objs = $ObjectiveContainer/ScrollContainer/VBoxContainer.get_children()
	print(objs)
	for child in objs:
		child.queue_free()
