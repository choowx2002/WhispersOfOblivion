extends Node2D
@onready var SceneSwitchAnimation = $SceneSwitchAnimation/AnimationPlayer
@onready var respawn_points := $RespawnPoints.get_children()
@onready var player := $TestingBody
@onready var hint_timer: Timer = $HintTimer
var hint_started := false
var maze_key := "south"
var StoryLabelScene = preload("res://scenes/ui/story_label.tscn")
var story_label: Node = null
var hint_index := 0
var gameRespawnPoint

func _ready():
	SceneSwitchAnimation.get_parent().get_node("ColorRect").color.a = 255
	SceneSwitchAnimation.play("FadeOut")
	if respawn_points.is_empty():
		push_error("No respawn points defined!")
		return

	var chosen_point = respawn_points[randi() % respawn_points.size()]
	gameRespawnPoint = chosen_point
	player.global_position = chosen_point.global_position
	
	var playerCamera: Camera2D = player.find_child("Camera2D")
	if playerCamera:
		playerCamera.limit_left = 0
		playerCamera.limit_top = 0
		playerCamera.limit_right = 1952
		playerCamera.limit_bottom = 1952
		
	
	# Create a timer just for hint messages
	hint_timer = Timer.new()
	hint_timer.wait_time = 30
	hint_timer.one_shot = false
	add_child(hint_timer)
	hint_timer.timeout.connect(_on_hint_timer_timeout)
	


func _process(_delta: float) -> void:
	if not hint_started \
	and GameState.has_picked_up_fragment(maze_key) \
	and not GameState.has_collected_fragment(maze_key):
		hint_timer.start()
		hint_started = true
		print("DEBUG: Hint timer started")


func get_maze_key() -> String:
	return "south"

func _unhandled_input(event):
	if event.is_action_pressed("toggle_setting"):
		if $CanvasLayer/Setting.visible:
			$CanvasLayer/Setting.hide()
			get_tree().paused = false
		else:
			$CanvasLayer/Setting.show()
			get_tree().paused = true

func _on_hint_timer_timeout() -> void:
	var maze_key = get_maze_key()
	# Only give hints if fragment picked up but not yet survived
	if GameState.has_picked_up_fragment(maze_key) and not GameState.has_collected_fragment(maze_key):
		if story_label == null:
			story_label = StoryLabelScene.instantiate()
			get_tree().root.add_child(story_label)
		
		_show_hint()
	else:
		# Stop hints once ending is reached or fragment is lost
		hint_timer.stop()
		story_label = null
		hint_index = 0

func _show_hint() -> void:
	# Cycle through a set of hints (you can make it random or sequential)
	var hints = [
		"Hmm… that shadow keeps moving… maybe it’s trying to show me something?",
		"The footsteps echo… not scary, more like… a friend leading the way?",
		"The shadow waits patiently… maybe it knows the secret to the fragment.",
		"Even if I’m scared, I think… I have to trust it a little.",
		"It almost looks like it wants me to follow… should I step closer?",
		"My hands feel warm from the fragment… maybe it likes the shadow too?",
		"The darkness isn’t so scary when I think it’s… watching over me.",
		"I wonder if the shadow is happy I’m here… I should stay still and see."
	]
	
	if story_label == null:
		return  # safety check
	
	# Show the current hint
	story_label.show_story(hints[hint_index])
	
	# Move to next hint (wrap around)
	hint_index = (hint_index + 1) % hints.size()
