extends CharacterBody2D

@export var speed: float = 100.0
@export var step_distance: float = 100.0

var path = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2.UP,
	Vector2.DOWN,
	Vector2.DOWN,
]

var current_step := 0
var start_position: Vector2
var target_position: Vector2
var moving := false

func _ready():
	start_position = global_position
	set_next_target()

func _physics_process(delta: float) -> void:
	if moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		if global_position.distance_to(target_position) < 1.0:
			global_position = target_position
			set_next_target()
	else:
		velocity = Vector2.ZERO

func set_next_target():
	if current_step < path.size():
		start_position = global_position
		target_position = start_position + path[current_step] * step_distance
		current_step += 1
		moving = true
