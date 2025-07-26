extends CharacterBody2D

# run animation
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
# player movement base speed（frame/sec）
@export var move_speed := 100
# declare if player ded
var is_dead: bool = false

func _physics_process(delta):
	# run dead animation
	if is_dead:
		if anim_sprite.animation != "died":
			anim_sprite.play("died")
		velocity = Vector2.ZERO
		return
	
	# Character facing
	look_at(get_global_mouse_position())
	
	# Get inputs
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# If shift is pressed, slow down (stealth mode)
	var speed_multiplier := 1.0
	if Input.is_action_pressed("stealth"):
		speed_multiplier = 0.33  # Slowdown multiplier
	
	# Move and animate
	if input_vector.length() > 0:
		# normalized movement speed
		input_vector = input_vector.normalized()
		# Calculate and apply movement
		velocity = input_vector * move_speed * speed_multiplier
		
		# Run moving animation
		if anim_sprite.animation != "move":
			anim_sprite.play("move")
	else:
		# run idle animation when vector = 0 (idle)
		velocity = Vector2.ZERO
		anim_sprite.play("idle")
	move_and_slide()
