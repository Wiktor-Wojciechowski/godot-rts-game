# SelectionRect.gd
extends Control

var is_selecting: bool = false
var selection_start: Vector2
var selection_end: Vector2

func start_selection(start: Vector2) -> void:
	selection_start = start
	selection_end = start
	is_selecting = true
	queue_redraw()  # Request a redraw when selection starts

func update_selection(end: Vector2) -> void:
	selection_end = end
	is_selecting = true
	queue_redraw()  # Request a redraw while dragging

func end_selection() -> void:
	is_selecting = false
	queue_redraw()  # Request a redraw when selection ends

func _draw() -> void:
	# Draw the selection rectangle when selecting
	if is_selecting:
		var rect = Rect2(selection_start, selection_end - selection_start).abs()
		draw_rect(rect, Color(0, 1, 0, 0.2), true)  # Filled rectangle
		draw_rect(rect, Color(0, 1, 0), false)  # Outline of the rectangle
