extends Label

@export var lifetime: float = 3.0
@export var fade_time: float = 1.0
@export var float_offset: Vector2 = Vector2(0, -50)
@export var min_font_size: int = 23
@export var max_font_size: int = 30
@export var rotation_range_deg: float = 12.0
@export var custom_font: FontFile

func _ready():
	randomize()
	
	if custom_font:
		add_theme_font_override("font", custom_font)
		
	var fs = int(randf_range(min_font_size, max_font_size))
	add_theme_font_size_override("font_size", fs)
	add_theme_color_override("font_color", Color(0.8, 0.8, 1.0, 0.7))

	rotation_degrees = randf_range(-rotation_range_deg, rotation_range_deg)

	var tween = create_tween()

	tween.tween_property(self, "position", position + float_offset, lifetime)

	var fade_tween = create_tween()
	fade_tween.tween_interval(lifetime - fade_time)
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_time)

	fade_tween.finished.connect(self.queue_free)
