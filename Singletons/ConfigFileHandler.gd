extends Node


var config = ConfigFile.new()
var SETTINGS_FILE_PATH = OS.get_executable_path() + "/settings.ini"

func _ready() -> void:
	print(SETTINGS_FILE_PATH)
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("audio", "music_volume", 0.5)
		config.set_value("audio", "sfx_volume", 0.5)
