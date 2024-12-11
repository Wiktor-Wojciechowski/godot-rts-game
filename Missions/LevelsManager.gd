extends Node

var available_levels: Array = [
	"res://Missions/MainMenu.tscn",
	"res://Missions/Campaign/Level1.tscn",
	"res://Missions/Campaign/Level2.tscn"
]

var current_level_index = 0

func _ready() -> void:
	var my_stringname = get_tree().current_scene.name
	var my_string = String(my_stringname)
	var trimmed_string = my_string.substr(5, my_string.length() - 5)
	var result = int(trimmed_string)
	current_level_index = result
	print(result)  # Output: 6789

func load_level(level_index: int):
	get_tree().change_scene_to_file(available_levels[level_index])
	current_level_index = level_index
	
	
func load_next_level():
	if can_load_next_level():
		load_level(current_level_index + 1)
		current_level_index += 1
		return
	print("Can't load next level")

func go_to_main_menu():
	get_tree().change_scene_to_file("res://Missions/MainMenu.tscn")
	current_level_index = 0

func can_load_next_level():
	return not current_level_index + 1 >= available_levels.size()

func can_load_level_with_index(index):
	if index >= available_levels.size() || index < 0:
		return false
	return not available_levels[index] == null
