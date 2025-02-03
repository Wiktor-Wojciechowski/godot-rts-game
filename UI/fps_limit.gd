extends SpinBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var settings = ConfigFileHandler.load_graphics_settings()
	value = settings.fps_limit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_value_changed(value: float) -> void:
	Engine.max_fps = value
	ConfigFileHandler.save_graphics_setting("fps_limit", value)
