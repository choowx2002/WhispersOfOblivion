extends CanvasLayer

signal confirmed
signal cancelled

func _ready():
	$Panel/VBoxContainer/HBoxContainer/YesButton.pressed.connect(_on_yes_pressed)
	$Panel/VBoxContainer/HBoxContainer/NoButton.pressed.connect(_on_no_pressed)
	# Pause the game when panel appears
	get_tree().paused = true

func _on_yes_pressed():
	get_tree().paused = false
	confirmed.emit()
	queue_free()

func _on_no_pressed():
	get_tree().paused = false
	cancelled.emit()
	queue_free()