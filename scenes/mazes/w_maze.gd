extends Node2D

@onready var respawn_points := $RespawnPoints.get_children()
@onready var player := $TestingBody
@onready var audio_players := {
	"N": $Sounds/WhisperNorth, # AudioStreamPlayer
	"E": $Sounds/WhisperEast,
	"S": $Sounds/WhisperSouth,
	"W": $Sounds/WhisperWest,
}
@onready var check_timer := $CheckTimer
var targets: Array[Node] = []
var gameRespawnPoint
var last_cell := Vector2(-1, -1)

func _ready():
	
	#get all targets
	targets = get_tree().get_nodes_in_group("whisper_targets")
	
	#bind timer trigger
	check_timer.connect("timeout", Callable(self, "_on_check_timer_timeout"))
	
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
	return "west"

func _on_check_timer_timeout():
	if targets.is_empty():
		return

	var nearest = get_nearest_target()
	if nearest == null:
		return

	# check direction
	var dir_vec = (nearest.global_position - player.global_position).normalized()
	var angle = rad_to_deg(atan2(dir_vec.y, dir_vec.x))

	var direction = angle_to_direction(angle)
	play_whisper(direction)

func get_nearest_target() -> Node2D:
	var nearest: Node2D = null
	var min_dist = INF
	for t in targets:
		var d = player.global_position.distance_to(t.global_position)
		if d < min_dist:
			min_dist = d
			nearest = t
	return nearest

func angle_to_direction(angle: float) -> String:
	if angle >= -45 and angle < 45:
		return "E"
	elif angle >= 45 and angle < 135:
		return "S"
	elif angle >= -135 and angle < -45:
		return "N"
	else:
		return "W"

func play_whisper(dir: String):
	if dir in audio_players:
		var p: AudioStreamPlayer = audio_players[dir]
		print("play sound", dir)
		if not p.playing:
			p.play()
