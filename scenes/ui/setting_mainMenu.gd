extends Control

@onready var back_button = $NinePatchRect/Back
@onready var settingLabel = $NinePatchRect/SettingLabel
func _ready():
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	settingLabel.text = "Setting"
	settingLabel.add_theme_font_size_override("font_size", 32)
	# Button labels
	back_button.text = "Back"
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	print("Back clicked")
	hide()  # hide this Setting panel itself
