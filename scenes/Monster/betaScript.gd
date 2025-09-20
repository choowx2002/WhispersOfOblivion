extends CharacterBody2D

@export var speed: float = 60.0
@export var patrol_area_path: NodePath
@export var detection_radius: float = 200.0
@export var change_dir_interval: float = 2.0

@onready var raycast: RayCast2D = $RayCast2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound = $AudioStreamPlayer2D
@onready var timer = $Timer
@export var ammo : PackedScene

var player: CharacterBody2D
var patrol_area: Area2D

var direction := Vector2.ZERO
var chase_timer := 0.0
var chasing := false
var returning := false
var patrol_timer := 0.0

# Navigation variables
var movement_delta: float
var next_path_position: Vector2
var new_velocity: Vector2

func _ready():
	player = get_parent().find_child("TestingBody", true, false)
	patrol_area = get_node(patrol_area_path)
	raycast.add_exception(self)
	_set_random_direction()
	patrol_timer = change_dir_interval
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	_aim()
	_check_player_collision()
	
	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()

	#update raycast
	raycast.visible = distance_to_player <= detection_radius
	raycast.target_position = to_player.normalized() * detection_radius
	raycast.force_raycast_update()
	
	if raycast.get_collider() != player:
		self.visible = false
	else:
		self.visible = true 
	
	#mnging state here
	var can_see_player = distance_to_player <= detection_radius and raycast.get_collider() == player
	
	if can_see_player and not chasing:
		chasing = true
		sound.play()
		returning = false
		chase_timer = 3.0  #reset chase timer
		print("chasing")
		
	elif chasing:
		if can_see_player:
			#reset timer if it can see the player
			chase_timer = 3.0
		else:
			#start count down if can't see player
			chase_timer -= delta
			if chase_timer <= 0:
				chasing = false
				returning = true
				print("returning")
	
	#movement execution
	if chasing:
		_chase_player(delta)
	elif returning:
		_return_to_patrol(delta, can_see_player)
	else:
		_patrol(delta)

func _chase_player(delta: float) -> void:
	navigation_agent_2d.set_target_position(player.global_position)
	
	if global_position.distance_to(player.global_position) >= 16:
		movement_delta = speed * delta
	else:
		movement_delta = 0
		
	if navigation_agent_2d.is_navigation_finished():
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		return
		
	next_path_position = navigation_agent_2d.get_next_path_position()
	new_velocity = global_position.direction_to(next_path_position) * movement_delta
	
	#update sprite rotation n animation
	if new_velocity.length() > 0:
		animated_sprite.rotation = new_velocity.angle() + PI / 2
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
	
	global_position = global_position.move_toward(global_position + new_velocity, movement_delta)

func _return_to_patrol(delta: float, can_see_player: bool) -> void:
	#if can see player while returning, chase state be handled in _physics_process
	#continue returning movement here
	var shape = patrol_area.get_node("CollisionShape2D")
	if shape and shape.shape is RectangleShape2D:
		var rect_size = shape.shape.size
		var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)
		
		if patrol_rect.has_point(global_position):
			#go back patrol area
			returning = false
			_set_random_direction()
			patrol_timer = change_dir_interval
			print("patrolling")
		else:
			#go towards the patrol area center
			direction = (patrol_rect.get_center() - global_position).normalized()
			
			if direction.length() > 0:
				animated_sprite.rotation = direction.angle() + PI / 2
				if animated_sprite.animation != "run":
					animated_sprite.play("run")
			
			velocity = direction * speed
			move_and_slide()
	else:
		direction = (patrol_area.global_position - global_position).normalized()
		
		if direction.length() > 0:
			animated_sprite.rotation = direction.angle() + PI / 2
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
		
		velocity = direction * speed
		move_and_slide()
		
		#check wether it's  close enough to the patrol area
		if global_position.distance_to(patrol_area.global_position) < 50:
			returning = false
			_set_random_direction()
			patrol_timer = change_dir_interval
			print("patrolling")

func _patrol(delta: float) -> void:
	patrol_timer -= delta
	
	#change direction periodically
	if patrol_timer <= 0:
		_set_random_direction()
		patrol_timer = change_dir_interval
	
	#check whether it's still in patrol area
	var shape = patrol_area.get_node("CollisionShape2D")
	if shape and shape.shape is RectangleShape2D:
		var rect_size = shape.shape.size
		var patrol_rect = Rect2(patrol_area.global_position - rect_size / 2, rect_size)
		
		#if is outside patrol area, move back in
		if not patrol_rect.has_point(global_position):
			direction = (patrol_rect.get_center() - global_position).normalized()
	
	if direction.length() > 0:
		animated_sprite.rotation = direction.angle() + PI / 2
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
	
	#move in current direction
	velocity = direction * speed
	move_and_slide()

func _set_random_direction():
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	
func _aim():
	raycast.target_position = to_local(player.position)
	
func _check_player_collision():
	if raycast.get_collider() == player and timer.is_stopped():
		timer.start()
	elif raycast.get_collider() != player and not timer.is_stopped():
		timer.stop()

func _on_timer_timeout() -> void:
	_shoot()

func _shoot():
	var fireball = ammo.instantiate()
	fireball.position = position
	fireball.direction = (raycast.target_position).normalized()
	get_tree().current_scene.add_child(fireball)
