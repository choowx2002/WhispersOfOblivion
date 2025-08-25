extends CharacterBody2D

var anim_sprite: AnimatedSprite2D # run animation
@export var move_speed := 100 # player movement base speed（frame/sec）
@onready var step_audio := $StepAudio
var surface_detector
var step_timer := 0.0
var base_interval := 0.45
var min_interval := 0.20
var is_dead: bool = false # declare if player ded

signal healthChanged
@export var maxHealth: float = 3.0 # set maximum health to 3 unit
var currentHealth: float = maxHealth # current heath status
<<<<<<< Updated upstream
@onready var heartsContainer = $HeartBar/HeartContainer

func _ready():
	heartsContainer.setMaxHearts(maxHealth) # show heart ui
	heartsContainer.updateHearts(currentHealth) # update the current heart
	healthChanged.connect(heartsContainer.updateHearts)
=======
@onready var heartsContainer = $HeartBar/HeartContainer #read the function in path
func _ready():
	currentHealth = maxHealth
	print("Player ready: current =", currentHealth, " max =", maxHealth)
	heartsContainer.setMaxHearts(maxHealth, currentHealth) # show heart ui
	heartsContainer.updateHearts(currentHealth) # update the current heart
	#healthChanged.connect(heartsContainer.updateHearts)
>>>>>>> Stashed changes
	anim_sprite = get_node("AnimatedSprite2D")
	surface_detector = get_tree().get_first_node_in_group("surface_detector")
	#connect("body_entered", Callable(self, "touch_enemy"))

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
	
	#detect speed and step sound
	var speed = velocity.length()
	
	if speed > 10:
		var ratio = speed / move_speed
		var step_interval = clamp(base_interval / ratio, min_interval, base_interval)
		step_timer -= delta
		
		if step_timer <= 0.0:
			step_timer = step_interval
			_play_step_sound()
	else:
		step_timer = 0.0
	
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox touched:", area.name)
	if is_dead:
		return
	if area.get_parent().is_in_group("Enemy"):  # check if enemy parent is in group
<<<<<<< Updated upstream
		currentHealth -= 1.0 # minus 1 heart while touched the hitbox
		healthChanged.emit(currentHealth) # show latest health status
		if currentHealth == 0:
=======
		currentHealth -= 1.0
		heartsContainer.updateHearts(currentHealth)
		if currentHealth <= 0:
>>>>>>> Stashed changes
			die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.play("died")
	await anim_sprite.animation_finished
	await get_tree().create_timer(1.0).timeout
	respawn()
	print("Player died.")

func respawn():
<<<<<<< Updated upstream
	maxHealth += 1
	if maxHealth >= 100:
		maxHealth -= 97 # clear the health in default 3 unit if reach 100 health limit
		return
	currentHealth = maxHealth
	global_position = get_tree().current_scene.gameRespawnPoint
	anim_sprite.play("idle")
	is_dead = false
	healthChanged.emit(currentHealth)
=======
	
	maxHealth += 1
	
	if maxHealth >= 100:
		maxHealth = 3
		return
		
	currentHealth = maxHealth
	print("Player respawn: current =", currentHealth, " max =", maxHealth)
	heartsContainer.setMaxHearts(maxHealth, currentHealth) # show heart ui
	heartsContainer.updateHearts(currentHealth) # update the current heart
	
	global_position = get_tree().current_scene.gameRespawnPoint
	anim_sprite.play("idle")
	is_dead = false
	
>>>>>>> Stashed changes
	set_physics_process(true)

func _play_step_sound():
	if not surface_detector:
		return

	var surface = surface_detector.get_surface_type(global_position)
	match surface:
		"ground":
			step_audio.stream = preload("res://assets/sounds/footstep.mp3")
		"grass":
			step_audio.stream = preload("res://assets/sounds/walking-on-grass.mp3")
		_:
			step_audio.stream = preload("res://assets/sounds/footstep.mp3")

	step_audio.pitch_scale = randf_range(0.95, 1.05)
	step_audio.play()
