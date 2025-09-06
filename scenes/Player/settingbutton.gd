extends Control

@onready var setting_button: Button = $ButtonSetting

func _ready():
	
	setting_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	setting_button.pressed.connect(_on_setting_button_pressed)
	
func _on_setting_button_pressed():
	print("Setting clicked")
	$CanvasLayer/Setting.show()
	get_tree().paused = true
