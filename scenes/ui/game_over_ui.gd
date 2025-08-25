extends Control

@onready var respawn_button: Button = $Button/NinePatchRect/RespawnHubRoom
@onready var main_menu_button: Button = $Button/NinePatchRect/MainMenu

func _ready():
	# Allow UI to process while the tree is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false  # hidden by default

	respawn_button.text = "Respawn"
	main_menu_button.text = "Main Menu"
	# Buttons
	respawn_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	respawn_button.pressed.connect(_on_respawn_button_pressed)
	main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_respawn_button_pressed():
	print("Respawn clicked")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/hub/HubRoom.tscn")

func _on_main_menu_button_pressed():
	print("Main Menu clicked")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
