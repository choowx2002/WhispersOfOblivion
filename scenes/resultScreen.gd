extends Control

@onready var main_menu_button: Button = $MarginContainer/NinePatchRect/ReturnMainMenu
@onready var ResultTitle: Label = $MarginContainer/NinePatchRect/ResultTitle
@onready var ResultContain: Label = $MarginContainer/NinePatchRect/ResultContain

func _ready() -> void:
	print("ResultScreen._ready()")

	# UI hidden by default
	visible = false  

	# Button setup
	main_menu_button.text = "Return to Main Menu"

	var callable = Callable(self, "_on_main_menu_button_pressed")
	if not main_menu_button.pressed.is_connected(callable):
		main_menu_button.pressed.connect(callable)

	# Labels
	
	ResultTitle.text = "Result:"
	ResultTitle.add_theme_font_size_override("font_size", 32)
	ResultContain.text = ""

func _on_main_menu_button_pressed() -> void:
	print("Main Menu clicked")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func format_time(seconds: float) -> String:
	var total_seconds = int(seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]
	
func set_results(hits: int, respawns: int, time_taken: float) -> void:
	var formatted_time = format_time(time_taken)
	ResultContain.text = "Hits: %d\n\n\nRespawns: %d\n\n\nTime Taken: %s" % [hits, respawns, formatted_time]
