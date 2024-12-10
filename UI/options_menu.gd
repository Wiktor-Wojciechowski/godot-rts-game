extends Control

@onready var display_mode = $Panel/GridContainer/DisplayModeOptionButton
@onready var back_button = $Panel/BackButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_mode.item_selected.connect(on_display_mode_selected)
	back_button.pressed.connect(on_back_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_display_mode_selected(index):
	match index:
		0:
			#Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			#Windowed
			
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

func on_back_button_pressed():
	hide()
