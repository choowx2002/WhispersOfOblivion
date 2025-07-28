extends CharacterBody2D

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D # run animation
@export var move_speed := 100 # player movement base speed（frame/sec）
var is_dead: bool = false # declare if player ded

func _ready():
	connect("body_entered", Callable(self, "touch_enemy"))

func _physics_process(delta):
	# run dead animation
	if is_dead:
		if anim_sprite.animation != "died":
			anim_sprite.play("died")
		velocity = Vector2.ZERO
		return
	
	# Get inputs
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# Character facing
	if input_vector.length() > 0:
		rotation = input_vector.angle()
	
	# If shift is pressed, slow down (stealth mode)
	var speed_multiplier := 1.0
	if Input.is_action_pressed("stealth"):
		speed_multiplier = 0.33  # Slowdown multiplier
	
	# Move and animate
	if input_vector.length() > 0:
		input_vector = input_vector.normalized() # normalized movement speed
		velocity = input_vector * move_speed * speed_multiplier # Calculate and apply movement
		
		# Run moving animation
		if anim_sprite.animation != "move":
			anim_sprite.play("move")
	else:
		# run idle animation when vector = 0 (idle)
		velocity = Vector2.ZERO
		anim_sprite.play("idle")
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox touched:", area.name)
	if is_dead:
		return
	if area.get_parent().is_in_group("Enemy"):  # check if enemy parent is in group
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.play("died")
	print("Player died.")
