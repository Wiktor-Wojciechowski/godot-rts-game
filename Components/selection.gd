extends Node3D

var is_selected: bool = false

func _ready() -> void:
	hide()

func select() -> void:
	is_selected = true
	show()

func deselect() -> void:
	is_selected = false
	hide()
