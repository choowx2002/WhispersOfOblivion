extends CharacterBody2D

@export var speed: float = 200.0

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D  # 用来左右翻转

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	# 播放动画
	if direction == Vector2.ZERO:
		_play_idle_animation()
	else:
		_play_walk_animation(direction)

func _play_idle_animation():
	var current = animator.current_animation
	if current.begins_with("walk_"):
		var dir = current.trim_prefix("walk_")
		animator.play("idle_" + dir)

func _play_walk_animation(direction: Vector2):
	if direction.y > 0:
		animator.play("walk_down")
	elif direction.y < 0:
		animator.play("walk_up")
	else:
		animator.play("walk_side")
		if direction.x != 0:
			sprite.flip_h = direction.x < 0  # 向左走时翻转 sprite
