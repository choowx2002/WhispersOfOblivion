extends Control

@onready var back_button = $NinePatchRect/Back
@onready var settingLabel = $NinePatchRect/SettingLabel
@onready var volumeLabel: Label = $NinePatchRect/Volume/Volume
@onready var brightLabel: Label = $NinePatchRect/Bright/BrightnessLabel
@onready var volume_slider: HSlider = $NinePatchRect/Volume/Volume/HSlider
@onready var brightness_slider: HSlider = $NinePatchRect/Bright/BrightnessLabel/HSlider

func _ready():
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Setup labels
	settingLabel.text = "Setting"
	settingLabel.add_theme_font_size_override("font_size", 32)
	back_button.text = "Back"
	back_button.pressed.connect(_on_back_button_pressed)

	# Load global settings into sliders
	volumeLabel.text = "\tVolume"
	volume_slider.value = GlobalSettings.volume * 100
	volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))

	brightLabel.text = "Brightness"
	brightness_slider.value = GlobalSettings.brightness * 100
	brightness_slider.connect("value_changed", Callable(self, "_on_brightness_changed"))

	# Apply brightness immediately
	_apply_brightness(GlobalSettings.brightness)

func _on_back_button_pressed():
	print("Back clicked")
	hide()

# Volume slider changed
func _on_volume_changed(value):
	var db = lerp(-80, 0, value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	GlobalSettings.volume = value / 100.0  # save globally

# Brightness slider changed
func _on_brightness_changed(value):
	var b = clamp(value / 100.0, 0, 1)
	GlobalSettings.brightness = b  # save globally
	_apply_brightness(b)

# Apply brightness to current scene
func _apply_brightness(value):
	var canvas_mod = get_tree().current_scene.get_node_or_null("CanvasModulate")
	if canvas_mod:
		canvas_mod.color = Color(value, value, value)
