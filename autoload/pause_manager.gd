extends Node


var settings_ui: Control = null

func _ready():
	# Load Setting panel once and add it to root
	settings_ui = load("res://scenes/ui/setting.tscn").instantiate()
	settings_ui.name = "setting"
	settings_ui.hide()
	settings_ui.set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	settings_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().root.add_child(settings_ui)

	# Connect ESC globally
	get_tree().connect("unhandled_input", Callable(self, "_on_unhandled_input"))

# Toggle panel with ESC
func _on_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC key
		if settings_ui.visible:
			resume_game()
		else:
			pause_game()

func pause_game():
	settings_ui.show()
	# pause tree, but allow PauseManager and settings_ui to process
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	get_tree().paused = true

func resume_game():
	settings_ui.hide()
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	get_tree().paused = false
