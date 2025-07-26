extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# default animation duration
var fade_time := 0.5  # seconds
var fading := false
var timer := 0.0

func _ready():
	sprite.modulate.a = 1.0
	connect("body_entered", Callable(self, "_on_Area2D_body_entered"))

func _process(delta: float) -> void:
	if fading:
		timer += delta
		var t: float = clamp(timer / fade_time, 0.0, 1.0)
		# Fade out
		sprite.modulate.a = lerp(1.0, 0.0, t)
		# Shrink
		sprite.scale = Vector2.ONE * lerp(0.1, 0.5, t)
		
		if t >= 1.0:
			queue_free()  # remove the item

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("player") and !fading:
		print("Player touched item!")
		fading = true
		collision.set_deferred("disabled", true)  # Prevent multiple triggers
