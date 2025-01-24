extends HSlider

@export var bus_name: String

var bus_index: int

func _ready() -> void:
	var audio_settings = ConfigFileHandler.load_audio_settings()
	match bus_name:
		"SFX":
			print("audios: ", audio_settings)
			value = audio_settings.sfx_volume
		"Music":
			value = audio_settings.music_volume
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	#value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	match bus_name:
		"SFX":
			ConfigFileHandler.save_audio_setting("sfx_volume", value)
		"Music":
			ConfigFileHandler.save_audio_setting("music_volume", value)
