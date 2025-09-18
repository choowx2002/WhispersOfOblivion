extends Control

@onready var back_button: Button = $Button/NinePatchRect/Back
@onready var main_menu_button: Button = $Button/NinePatchRect/MainMenu
@onready var settingLabel: Label = $Button/NinePatchRect/SettingLabel
@onready var volumeLabel: Label = $Button/NinePatchRect/Sound/Volume
@onready var brightLabel: Label = $Button/NinePatchRect/Bright/Brightness
@onready var volume_slider: HSlider = $Button/NinePatchRect/Sound/HSlider
@onready var brightness_slider: HSlider = $Button/NinePatchRect/Bright/HSlider

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP

	# UI labels
	settingLabel.text = "Settings"
	settingLabel.add_theme_font_size_override("font_size", 20)
	back_button.text = "Back"
	main_menu_button.text = "Main Menu"

	back_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_button.pressed.connect(_on_back_pressed)
	main_menu_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Setup sliders using global settings
	volumeLabel.text = "\tVolume"
	volume_slider.value = GlobalSettings.volume * 100
	volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))

	brightLabel.text = "Brightness"
	brightness_slider.value = GlobalSettings.brightness * 100
	brightness_slider.connect("value_changed", Callable(self, "_on_brightness_changed"))

	# Apply immediately
	_apply_volume()
	_apply_brightness()

func _unhandled_input(event: InputEvent) -> void:
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

func _pause_game():
	show()
	get_tree().paused = true

func _resume_game():
	hide()
	get_tree().paused = false

# ---------------------------
# Volume / Brightness handlers
# ---------------------------

func _on_volume_changed(value):
	GlobalSettings.volume = value / 100.0
	_apply_volume()

func _on_brightness_changed(value):
	GlobalSettings.brightness = value / 100.0
	_apply_brightness()

func _apply_volume():
	var db = lerp(-80, 0, GlobalSettings.volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _apply_brightness():
	var canvas_mod = get_tree().current_scene.get_node_or_null("CanvasModulate")
	if canvas_mod:
		var c = clamp(GlobalSettings.brightness, 0, 1)
		canvas_mod.color = Color(c, c, c)
