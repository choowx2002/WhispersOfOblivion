extends Control

@onready var back_button: Button = $Button/NinePatchRect/Back
@onready var main_menu_button: Button = $Button/NinePatchRect/MainMenu
@onready var settingLabel = $Button/NinePatchRect/SettingLabel
func _ready():
	# Allow UI to process while the tree is paused
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	settingLabel.text = "Setting"
	settingLabel.add_theme_font_size_override("font_size", 32)
	back_button.text = "Back"
	main_menu_button.text = "Main Menu"
	
	# Buttons
	back_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_button.pressed.connect(_on_back_button_pressed)
	main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
func _on_back_button_pressed():
	print("Back clicked")
	hide()  # this hides the setting menu

func _on_main_menu_button_pressed():
	print("Main Menu clicked")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	hide()
