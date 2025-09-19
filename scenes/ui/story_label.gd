extends CanvasLayer

@onready var label = $Label
var display_time: float = 5.0  # How long to show the message
var fade_in_time: float = 1.0  # How long to fade in
var fade_out_time: float = 1.0 # How long to fade out
var timer: float = 0.0
var state: String = "fade_in"  # States: fade_in, display, fade_out

func _ready():
	# Hide by default
	visible = false
	label.modulate.a = 0.0

func _process(delta):
	if not visible:
		return
		
	timer += delta
	
	match state:
		"fade_in":
			var t = timer / fade_in_time
			label.modulate.a = t
			if t >= 1.0:
				state = "display"
				timer = 0.0
		
		"display":
			if timer >= display_time:
				state = "fade_out"
				timer = 0.0
		
		"fade_out":
			var t = timer / fade_out_time
			label.modulate.a = 1.0 - t
			if t >= 1.0:
				queue_free()

func show_story(text: String):
	label.text = text
	visible = true
	label.modulate.a = 0.0  # Start fully transparent
	timer = 0.0
	state = "fade_in"
