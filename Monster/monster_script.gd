extends CharacterBody2D

@export var speed: float = 60.0
@export var patrol_area_path: NodePath
@export var chase_duration: float = 10.0
@export var detection_radius: float = 200.0
@export var change_dir_interval: float = 2.0  # 新增：巡逻时多久换方向

@onready var raycast: RayCast2D = $RayCast2D
var player: CharacterBody2D
var patrol_area: Area2D

var direction := Vector2.ZERO
var chase_timer := 0.0
var direction_timer := 0.0
var chasing := false
var returning := false
@onready  var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@export var movement_delta:float
@export var next_path_position:Vector2
@export  var new_velocity:Vector2


func _ready():
	player = get_parent().find_child("Player", true, false)
	patrol_area = get_node(patrol_area_path)
	raycast.add_exception(self)
	_set_random_direction()

func _physics_process(delta:float)->void:
	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()

	# 控制 RayCast 可视
	raycast.visible = distance_to_player <= detection_radius
	raycast.target_position = to_player.normalized() * detection_radius
	raycast.force_raycast_update()
	
	if raycast.get_collider() != player:
		self.visible = false
	else:
		self.visible = true 
	
	if not chasing and not returning:
		if distance_to_player <= detection_radius and raycast.get_collider() == player:
			print("START CHASING")
			chasing = true
	if chasing:
		print("chasing")
		if raycast.get_collider() == player:
			move_enemy(delta)
		else:
			chase_timer -= delta
			if chase_timer <= 0:
				print("chase timeout")
				chasing = false
				returning = true
	elif returning:
		# print("back to patrol")
		var center = patrol_area.global_position
		direction = (center - global_position).normalized()

		var shape = patrol_area.get_node("CollisionShape2D")
		if shape and shape.shape is RectangleShape2D:
			var rect_size = shape.shape.extents * 2
			var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)

			if patrol_rect.has_point(global_position):
				returning = false
				direction_timer = change_dir_interval
				_set_random_direction()

	# 巡逻中
	elif not chasing:
		#print("patrol")
		var shape = patrol_area.get_node("CollisionShape2D")
		if shape and shape.shape is RectangleShape2D:
			var rect_size = shape.shape.extents * 2
			var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)

			# 偏离 patrol 区了就走回去
			if not patrol_rect.has_point(global_position):
				direction = (patrol_rect.get_center() - global_position).normalized()
			else:
				direction_timer -= delta
				if direction_timer <= 0:
					direction_timer = change_dir_interval
					_set_random_direction()

	## 移动
	if !chasing:
		velocity = direction * speed
		move_and_slide()
	
	
func move_enemy(delta:float)->void:
	navigation_agent_2d.set_target_position(player.global_position)
	if global_position.distance_to(player.get_global_position())>=16:
		movement_delta=40*delta
	else:
		movement_delta=0
	next_path_position=navigation_agent_2d.get_next_path_position()
	new_velocity=global_position.direction_to(next_path_position)*movement_delta
	move_to_destination(new_velocity)
	
func move_to_destination(new_velocity:Vector2)->void:
	global_position=global_position.move_toward(global_position+new_velocity,movement_delta)
	

#
#func _physics_process(delta):
#
	#var to_player = player.global_position - global_position
	#var distance_to_player = to_player.length()
#
	## 控制 RayCast 可视
	#raycast.visible = distance_to_player <= detection_radius
	#raycast.target_position = to_player.normalized() * detection_radius
	#raycast.force_raycast_update()
#
	## 检测：不是追逐、也不是返回时，才检测玩家
	#if not chasing and not returning:
		#if distance_to_player <= detection_radius and raycast.get_collider() == player:
			#print("START CHASING")
			#chasing = true
			#chase_timer = chase_duration
#
	## 追逐中
	#if chasing:
		#if raycast.get_collider() == player:
			#print("chasing player")
			#direction = to_player.normalized()
		#else:
			#chase_timer -= delta
			#if chase_timer <= 0:
				#print("chase timeout")
				#chasing = false
				#returning = true
#
	## 回到巡逻区中心
	#elif returning:
		## print("back to patrol")
		#var center = patrol_area.global_position
		#direction = (center - global_position).normalized()
#
		#var shape = patrol_area.get_node("CollisionShape2D")
		#if shape and shape.shape is RectangleShape2D:
			#var rect_size = shape.shape.extents * 2
			#var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)
#
			#if patrol_rect.has_point(global_position):
				#returning = false
				#direction_timer = change_dir_interval
				#_set_random_direction()
#
	## 巡逻中
	#elif not chasing:
		#print("patrol")
		#var shape = patrol_area.get_node("CollisionShape2D")
		#if shape and shape.shape is RectangleShape2D:
			#var rect_size = shape.shape.extents * 2
			#var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)
#
			## 偏离 patrol 区了就走回去
			#if not patrol_rect.has_point(global_position):
				#direction = (patrol_rect.get_center() - global_position).normalized()
			#else:
				#direction_timer -= delta
				#if direction_timer <= 0:
					#direction_timer = change_dir_interval
					#_set_random_direction()
#
	## 移动
	#velocity = direction * speed
	#move_and_slide()

func _set_random_direction():
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
