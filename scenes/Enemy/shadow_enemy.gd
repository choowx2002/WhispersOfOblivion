extends CharacterBody2D

@export var speed: float = 80.0
@export var follow_delay: int = 100
@export var start_follow_time: float = 5.0
@export var record_interval: float = 0.1
@export var show_debug: bool = true
@export var follow_duration: float = 30.0
@export var respawn_delay: float = 5.0
@export var player: Node2D
@export var disappear_distance: float = 16.0

@onready var anim: AnimatedSprite2D = $ShadowAnim
@onready var collision_shape: CollisionShape2D = $ShadowCollision

enum ShadowState {IDLE, FADE_IN, FOLLOWING, HIDDEN}
var state: ShadowState = ShadowState.IDLE

var trail: Array[Vector2] = []
var player_moving_time: float = 0.0
var last_player_pos: Vector2
var record_timer: float = 0.0
var fade_timer: float = 0.0
var follow_timer: float = 0.0
var hide_timer: float = 0.0

func _ready():
	last_player_pos = player.global_position
	anim.animation = "idle"
	modulate.a = 0.0
	collision_shape.disabled = true

func _physics_process(delta: float) -> void:
	if not player:
		return

	record_timer += delta
	if record_timer >= record_interval:
		record_timer = 0.0
		trail.append(player.global_position)
	while trail.size() > follow_delay:
		trail.pop_front()

	var player_is_moving = (player.global_position - last_player_pos).length() > 0.1
	last_player_pos = player.global_position

	match state:
		ShadowState.IDLE:
			if player_is_moving:
				player_moving_time += delta
				if player_moving_time >= start_follow_time and trail.size() > 0:
					global_position = trail[0]
					state = ShadowState.FADE_IN
					fade_timer = 0.0
					modulate.a = 0.0
					collision_shape.disabled = false

		ShadowState.FADE_IN:
			fade_timer += delta
			modulate.a = clamp(fade_timer / 1.0, 0.0, 1.0)
			if modulate.a >= 1.0:
				state = ShadowState.FOLLOWING
				follow_timer = 0.0

		ShadowState.FOLLOWING:
			follow_timer += delta
			smooth_move_along_trail(delta)
			check_player_collision()
			if follow_timer >= follow_duration:
				hide_shadow()

		ShadowState.HIDDEN:
			hide_timer += delta
			if hide_timer >= respawn_delay:
				state = ShadowState.IDLE
				player_moving_time = 0.0

	update_animation_and_direction()

	if show_debug:
		queue_redraw()

func smooth_move_along_trail(delta: float) -> void:
	if trail.size() == 0:
		velocity = Vector2.ZERO
		return

	var target = trail[0]
	velocity = (target - global_position)
	if velocity.length() > 0.1:
		velocity = velocity.normalized() * speed
		global_position += velocity * delta
	else:
		velocity = Vector2.ZERO

	if global_position.distance_to(target) < 2.0:
		trail.pop_front()

func update_animation_and_direction() -> void:
	var is_running = velocity.length() > 0.1
	if is_running:
		if anim.animation != "move":
			anim.animation = "move"
	else:
		if anim.animation != "idle":
			anim.animation = "idle"

	if is_running:
		rotation = velocity.angle()

func check_player_collision() -> void:
	if global_position.distance_to(player.global_position) <= disappear_distance:
		hide_shadow()

func hide_shadow() -> void:
	state = ShadowState.HIDDEN
	hide_timer = 0.0
	modulate.a = 0.0
	collision_shape.disabled = true
	state = ShadowState.IDLE
	player_moving_time = 0.0
