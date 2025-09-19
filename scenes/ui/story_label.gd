extends CanvasLayer

@onready var label = $Label
var display_time: float = 5.0  # How long to show the message
var fade_time: float = 1.0     # How long to fade out
var timer: float = 0.0
var is_fading: bool = false

func _ready():
	# Hide by default
	visible = false
	label.modulate.a = 1.0

func _process(delta):
	if not visible:
		return
		
	timer += delta
	
	if timer >= display_time and not is_fading:
		is_fading = true
		timer = 0
	
	if is_fading:
		var t = timer / fade_time
		label.modulate.a = 1.0 - t
		
		if t >= 1.0:
			queue_free()

func show_story(text: String):
	label.text = text
	visible = true
	label.modulate.a = 1.0
	timer = 0.0
	is_fading = false
