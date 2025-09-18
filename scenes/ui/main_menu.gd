extends Control

@onready var title = $Button/NinePatchRect/Label
func _ready():
	# Get the button by its node path
	title.text = "Whispers Of Oblivion"
	title.add_theme_font_size_override("font_size", 50)
	var play_button = $Button/NinePatchRect/Play
	play_button.text = "Play"
	play_button.pressed.connect(_on_play_button_pressed)
	
	var setting_button = $Button/NinePatchRect/Setting
	setting_button.text = "Setting"
	setting_button.pressed.connect(_on_setting_button_pressed)
	
	var exit_button = $Button/NinePatchRect/Exit
	exit_button.text = "Exit"
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	$Button/NinePatchRect/CanvasLayer/Setting.hide()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/hub/HubRoom.tscn") # redirect to hub room
	
func _on_setting_button_pressed():
	$Button/NinePatchRect/CanvasLayer/Setting.show()
	
func _on_exit_button_pressed():
	get_tree().quit()  # closes the game window
