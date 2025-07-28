extends CharacterBody2D

@export var speed: float = 60.0
@export var player_path: NodePath
@export var chase_duration: float = 3.0
@export var detection_radius: float = 100.0

var player: Node2D
var direction := Vector2.ZERO
var chase_timer := 0.0
var chasing := false
var current_point_index := 0
var patrol_points: Array[Vector2] = []  # 巡逻路线坐标点

func _ready():
	player = get_node(player_path)

	# 自动读取 Marker2D 巡逻点（放在 PatrolPath 节点下）
	var path_node = $PatrolPath
	for child in path_node.get_children():
		if child is Marker2D:
			patrol_points.append(child.global_position)

func _physics_process(delta):
	if not player:
		return

	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()

	# 状态切换：侦测到玩家就追
	if not chasing and distance_to_player <= detection_radius:
		chasing = true
		chase_timer = chase_duration

	# 追逐模式
	if chasing:
		chase_timer -= delta
		direction = to_player.normalized()

		if chase_timer <= 0:
			chasing = false

	# 巡逻模式
	elif patrol_points.size() > 0:
		var target_point = patrol_points[current_point_index]
		var to_target = target_point - global_position

		if to_target.length() < 10.0:
			current_point_index = (current_point_index + 1) % patrol_points.size()

		direction = to_target.normalized()

	# 移动
	velocity = direction * speed
	move_and_slide()
