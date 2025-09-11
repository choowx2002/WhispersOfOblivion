extends Control

@onready var back_button: Button = $Button/NinePatchRect/Back
@onready var main_menu_button: Button = $Button/NinePatchRect/MainMenu
@onready var settingLabel: Label = $Button/NinePatchRect/SettingLabel

func _ready():
	hide()  # Start hidden
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Setup UI
	settingLabel.text = "Settings"
	settingLabel.add_theme_font_size_override("font_size", 32)
	back_button.text = "Back"
	main_menu_button.text = "Main Menu"

	back_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_button.pressed.connect(_on_back_pressed)
	main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_back_pressed():
	print("Back clicked")
	hide()
	PauseManager.resume_game()  # Resume game via global PauseManager

func _on_main_menu_pressed():
	print("Main Menu clicked")
	hide()
	PauseManager.resume_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
