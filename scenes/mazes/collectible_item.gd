extends Area2D

@export var item_id: String = "memory_fragment"
@export var auto_pickup: bool = true  # 自动捡还是按键
@export var fade_time: float = 0.5    # Fade out duration

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var fading: bool = false
var timer: float = 0.0
var start_scale: Vector2

func _ready():
	sprite.modulate.a = 1.0
	start_scale = sprite.scale  # Store original item scale
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Handle fade-out animation
	if fading:
		timer += delta
		var t: float = clamp(timer / fade_time, 0.0, 1.0)
		# Fade transparency
		sprite.modulate.a = lerp(1.0, 0.0, t)
		# Shrink sprite
		sprite.scale = lerp(start_scale, start_scale * 2.0, t)
		if t >= 1.0:
			queue_free()

func _on_body_entered(body: Node) -> void:
	# Only trigger for player
	if body.name != "TestingBody":
		print("Player touched collectible")
		return
	if auto_pickup:
		_collect(body)

func _collect(body: Node):
	_collect_fragment()
	_start_fade()
	print("Player collected item:", item_id)
	
# Mark memory fragment collected
func _collect_fragment():
	var maze_key := ""
	var scene := get_tree().current_scene
	if scene and scene.has_method("get_maze_key"):
		maze_key = scene.get_maze_key()
	print("Player pickup collectible in maze:", maze_key, " Item ID:", item_id)
	
	if item_id == "memory_fragment" and maze_key != "":
		GameState.mark_fragment_collected(maze_key)
		print("✅ Marked fragment as collected for ", maze_key)
	else:
		print("❌ Not marking fragment collected")

# Start fade-out animation
func _start_fade():
	fading = true
	collision.set_deferred("disabled", true)
