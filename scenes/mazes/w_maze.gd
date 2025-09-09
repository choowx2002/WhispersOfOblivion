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

# for world word text
@export var word_scene: PackedScene = preload("res://scenes/ui/WordLabel.tscn")
@export var words := {
	"N": "North",
	"E": "East",
	"S": "South",
	"W": "West",
}
@export var max_active_labels: int = 10
@export var spawn_margin: int = 50
@onready var effect_container: Control = $CanvasLayer/Effect/WordContainer

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
	for i in 5:
		var rand_text = words[direction]
		spawn_word(rand_text)
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

func spawn_word(text):
	if effect_container == null: return
	
	# limit count
	if effect_container.get_child_count() >= max_active_labels:
		effect_container.get_child(0).queue_free()

	var label = word_scene.instantiate() as Label
	label.text = text

	var viewport_size = get_viewport_rect().size
	
	var px = randf_range(spawn_margin, viewport_size.x - spawn_margin)
	var py = randf_range(spawn_margin, viewport_size.y - spawn_margin)
	
	label.position = Vector2(px, py)
	var dir = -1 if randi() % 2 == 0 else 1
	label.float_offset = Vector2(
		randf_range(20, 50) * dir,
		randf_range(-80, -40)
	)
	effect_container.add_child(label)
