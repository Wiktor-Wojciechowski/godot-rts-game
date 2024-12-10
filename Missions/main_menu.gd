extends Control

@onready var campaign_button = $Panel/VBoxContainer/CampaignButton
@onready var options_button = $Panel/VBoxContainer/OptionsButton
@onready var quit_game_button = $Panel/VBoxContainer/QuitGameButton


func _ready() -> void:
	campaign_button.pressed.connect(on_campaign_button_pressed)
	options_button.pressed.connect(on_options_button_pressed)
	quit_game_button.pressed.connect(on_quit_game_button_pressed)

func on_campaign_button_pressed():
	$CampaignMenu.show()

func on_options_button_pressed():
	$OptionsMenu.show()

func on_quit_game_button_pressed():
	get_tree().quit()
