extends Node2D
@onready var SceneSwitchAnimation = $SceneSwitchAnimation/AnimationPlayer
@onready var respawn_points := $RespawnPoints.get_children()
@onready var player := $TestingBody
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

func get_maze_key() -> String:
	return "south"
