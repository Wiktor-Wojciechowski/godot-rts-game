extends Control

@onready var campaign_button = $Panel/VBoxContainer/CampaignButton
@onready var options_button = $Panel/VBoxContainer/OptionsButton
@onready var quit_game_button = $Panel/VBoxContainer/QuitGameButton
@onready var credits_button = $Panel/VBoxContainer/Credits


func _ready() -> void:
	campaign_button.pressed.connect(on_campaign_button_pressed)
	options_button.pressed.connect(on_options_button_pressed)
	quit_game_button.pressed.connect(on_quit_game_button_pressed)
	credits_button.pressed.connect(on_credits_button_pressed)

func on_campaign_button_pressed():
	$CampaignMenu.show()

func on_options_button_pressed():
	$OptionsMenu.show()

func on_credits_button_pressed():
	$CreditsScreen.show()

func on_quit_game_button_pressed():
	get_tree().quit()
