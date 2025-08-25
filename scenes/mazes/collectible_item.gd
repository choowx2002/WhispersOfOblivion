extends Area2D

@export var item_id: String = "memory_fragment"
@export var auto_pickup: bool = true  # 自动捡还是按键
@export var fade_time: float = 0.5    # Fade out duration

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var fading: bool = false
var timer: float = 0.0
var start_scale: Vector2
var maze_key: String = ""

func _ready():
	sprite.modulate.a = 1.0
	start_scale = sprite.scale  # Store original item scale
	body_entered.connect(_on_body_entered)

	# Get maze name on load
	var scene := get_tree().current_scene
	if scene and scene.has_method("get_maze_key"):
		maze_key = scene.get_maze_key()
		print("DEBUG: Collectible initialized in maze: ", maze_key)
		
		# Verify collection state
		if item_id == "memory_fragment" and maze_key != "":
			var is_collected = GameState.has_collected_fragment(maze_key)
			print("DEBUG: Fragment collection state for ", maze_key, ": ", is_collected)
			if is_collected:
				queue_free()
				return
	else:
		push_warning("Scene missing get_maze_key() method!")

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
		return
	
	if auto_pickup and not GameState.has_collected_fragment(maze_key):
		_collect(body)

func _collect(body: Node):
	if item_id == "memory_fragment" and maze_key != "":
		if not GameState.has_collected_fragment(maze_key):
			GameState.mark_fragment_collected(maze_key)
			print("DEBUG: Fragment collected in maze: ", maze_key)
			_start_fade()
		else:
			print("DEBUG: Fragment already collected in maze: ", maze_key)
	
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
