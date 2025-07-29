extends Node2D

@onready var player := $TestingBody
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var playerCamera: Camera2D = player.find_child("Camera2D")
	if playerCamera:
		playerCamera.limit_left = -32
		playerCamera.limit_top = -32
		playerCamera.limit_right = 384
		playerCamera.limit_bottom = 320
		playerCamera.zoom = Vector2(4.8, 4.8)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_enterMaze()

func _enterMaze():
		if GameState.playerSelectedRoom:
			get_tree().change_scene_to_file(GameState.playerSelectedRoom)
