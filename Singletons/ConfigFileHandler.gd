extends Node


var config = ConfigFile.new()
var SETTINGS_FILE_PATH = "user://settings.ini"

func _ready() -> void:
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		print("creating file")
		config.set_value("audio", "music_volume", 0.5)
		config.set_value("audio", "sfx_volume", 0.5)
		config.set_value("graphics", "fps_limit", 144)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)

func save_audio_setting(key:String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_graphics_setting(key:String, value):
	config.set_value("graphics", key, value)
	config.save(SETTINGS_FILE_PATH)
	
func load_graphics_settings():
	var graphics_settings = {}
	for key in config.get_section_keys("graphics"):
		graphics_settings[key] = config.get_value("graphics", key)
	return graphics_settings
