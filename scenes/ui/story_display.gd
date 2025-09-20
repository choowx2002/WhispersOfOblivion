extends CanvasLayer

@onready var title_label = $Panel/Title
@onready var story_text = $Panel/StoryText
@onready var continue_button = $Panel/ContinueButton

signal story_finished

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	# Hide by default
	visible = false

func show_story(title: String, text: String):
	# Set the text
	title_label.text = title
	story_text.text = text
	
	# Show the display
	visible = true
	
	# Pause the game while showing story
	get_tree().paused = true

func _on_continue_pressed():
	visible = false
	get_tree().paused = false
	story_finished.emit()
