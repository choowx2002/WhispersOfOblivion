extends Control

@onready var setting_button: Button = $ButtonSetting
@onready var setting_panel: Control = $CanvasLayer/Setting

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	setting_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	setting_button.pressed.connect(_on_setting_button_pressed)

	# Make sure panel starts hidden
	setting_panel.hide()

func _on_setting_button_pressed():
	print("Setting button clicked")
	setting_panel.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
