extends Node2D

@onready var SceneSwitchAnimation = $SceneSwitchAnimation/AnimationPlayer
@onready var SceneSwitchColorRect = $SceneSwitchAnimation/ColorRect
@onready var player := $TestingBody
@onready var collection_display = $CollectionDisplay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneSwitchColorRect.color.a = 255
	SceneSwitchAnimation.play("FadeOut")
	var playerCamera: Camera2D = player.find_child("Camera2D")
	if playerCamera:
		playerCamera.limit_left = -32
		playerCamera.limit_top = -32
		playerCamera.limit_right = 384
		playerCamera.limit_bottom = 320
		playerCamera.zoom = Vector2(4.8, 4.8)

# Function to display collectables in maze
func _enter_tree():
	if collection_display:
		collection_display.update_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_enterMaze()

func _enterMaze():
		if GameState.playerSelectedRoom:
			SceneSwitchAnimation.play("FadeIn")
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file(GameState.playerSelectedRoom)
			
func _unhandled_input(event):
	if event.is_action_pressed("toggle_setting"):
		if $CanvasLayer/Setting.visible:
			$CanvasLayer/Setting.hide()
			get_tree().paused = false
		else:
			$CanvasLayer/Setting.show()
			get_tree().paused = true
