extends Node3D

var is_selected: bool = false

signal selected
signal deselected

func _ready() -> void:
	hide()

func select() -> void:
	is_selected = true
	emit_signal("selected")
	show()

func deselect() -> void:
	is_selected = false
	emit_signal("deselected")
	hide()
