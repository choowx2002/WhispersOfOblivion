extends Control

@onready var back_button: Button = $Button/NinePatchRect/Back
@onready var main_menu_button: Button = $Button/NinePatchRect/MainMenu
@onready var settingLabel: Label = $Button/NinePatchRect/SettingLabel

func _ready():
	# Start hidden
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP

	# UI labels
	settingLabel.text = "Settings"
	settingLabel.add_theme_font_size_override("font_size", 20)
	back_button.text = "Back"
	main_menu_button.text = "Main Menu"

	# Button signals
	back_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_button.pressed.connect(_on_back_pressed)
	main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Listen for ESC key (or your custom input map)
	if event.is_action_pressed("toggle_setting"):
		if visible:
			_resume_game()
		else:
			_pause_game()

func _on_back_pressed():
	print("Back clicked")
	_resume_game()

func _on_main_menu_pressed():
	print("Main Menu clicked")
	_resume_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# Local pause/unpause functions
func _pause_game():
	show()
	get_tree().paused = true

func _resume_game():
	hide()
	get_tree().paused = false
