extends CharacterBody2D

var anim_sprite: AnimatedSprite2D # run animation
@export var move_speed := 100 # player movement base speed（frame/sec）
var stealth_multiplier: float = 1.0
var external_multiplier: float = 1.0
var fireball_hit_multiplier: float = 1.0

@onready var step_audio := $StepAudio
@onready var timer = $Timer
var fireball_timer: Timer

var surface_detector
var step_timer := 0.0
var base_interval := 0.45
var min_interval := 0.20
var is_dead: bool = false # declare if player ded

@export var whisper_audio : AudioStreamPlayer
var last_pulse_time: float = -10.0
var pulse_interval: float = 10.0

@export var sanity_effect_rect: ColorRect

#signal healthChanged
#@export var maxHealth: float = 3.0 # set maximum health to 3 unit
#var currentHealth: float = maxHealth # current heath status
var hit_count: int = 0
var respawn_count: int = 0

#@onready var heartsContainer = $HeartBar/HeartContainer
var sanityTimer: Timer
var maxSanity = 100.0
var currentSanity = 100.0

@onready var sanityContainer = $Sanity/SanityContainer
@onready var gameOverUI = $GameOverUI/GameOverUI
@onready var sanityLabel = $Sanity/SanityLabel
@onready var SceneSwitchAnimation = $SceneSwitchAnimation/AnimationPlayer
@onready var interact_label = $"../CanvasLayer/InteractiveUI/InteractiveLabel"
@onready var sprite = $AnimatedSprite2D

func _ready():
	if GameState.start_time == 0.0:
		GameState.start_time = Time.get_ticks_msec() / 1000.0  # seconds since game start
	gameOverUI.visible = false
	sanityContainer.setMaxSanity(maxSanity, currentSanity)
	# Timer to reduce sanity every 10s
	sanityTimer = Timer.new()
	sanityTimer.wait_time = 30
	sanityTimer.one_shot = false
	sanityTimer.timeout.connect(_on_sanity_tick)
	add_child(sanityTimer)
	sanityTimer.start()
	anim_sprite = get_node("AnimatedSprite2D")
	surface_detector = get_tree().get_first_node_in_group("surface_detector")
	
	if sanity_effect_rect == null:
		var rect = get_tree().root.find_child("SanityEffectRect", true, false)
		if rect and rect is ColorRect:
			sanity_effect_rect = rect
		else:
			push_warning("SanityEffectRect not found!")
	#connect("body_entered", Callable(self, "touch_enemy"))
	
	if interact_label:
		interact_label.hide()
	
	#set timer for fire_hit_multiplier
	fireball_timer = Timer.new()
	fireball_timer.wait_time = 0.5
	fireball_timer.one_shot = true
	fireball_timer.timeout.connect(_on_fireball_timer_timeout)
	add_child(fireball_timer)
	
func _process(_delta):
	var time = Time.get_ticks_msec() / 1000.0
	var cycle_time = fmod(time, pulse_interval)
	if cycle_time < 0.02 and time - last_pulse_time > pulse_interval - 0.01:
		play_whisper()
		last_pulse_time = time

	if interact_label and interact_label.visible and sprite:
		var camera := get_viewport().get_camera_2d()
		if camera:
			# Use the sprite's position in world space
			var screen_pos: Vector2 = camera.get_canvas_transform() * sprite.global_position
			# Offset label above the sprite
			interact_label.position = screen_pos + Vector2(0, -40)

func show_interact_prompt():
	interact_label.visible = true

func hide_interact_prompt():
	interact_label.visible = false

func _on_sanity_tick():
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name != "HubRoom":
		change_sanity(-0.01 * maxSanity)  # -0.01% of max each 10s

func change_sanity(amount: float):
	currentSanity = clamp(currentSanity + amount, 0, maxSanity)
	sanityContainer.updateSanity(currentSanity)
	sanityLabel.text = str(round(currentSanity)) + "%"
	update_sanity_effect()
		
	if currentSanity <= 0:
		die_from_sanity()

func update_sanity_effect():
	if sanity_effect_rect == null:
		return
	if sanity_effect_rect.material == null:
		return
	
	var ratio = currentSanity / maxSanity
	if ratio <= 0:
		sanity_effect_rect.visible = false
		return
	sanity_effect_rect.visible = true
	sanity_effect_rect.material.set("shader_param/sanity", ratio)

func play_whisper():
	if whisper_audio == null or currentSanity >= 70:
		return
	whisper_audio.pitch_scale = randf_range(0.95, 1.05)
	var sanity_norm = currentSanity / 100.0
	whisper_audio.volume_db = lerp(-20, 0, 1.0 - sanity_norm)
	whisper_audio.stop()
	whisper_audio.play()
	#
	#await get_tree().create_timer(3.0).timeout
	#whisper_audio.stop()
	
func die_from_sanity():
	show_game_over()
	
func _physics_process(_delta):
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
		anim_sprite.rotation = input_vector.angle() - PI / 2
	
	# If shift is pressed, slow down (stealth mode)
	stealth_multiplier = 0.33 if Input.is_action_pressed("stealth") else 1.0
	
	# 根据 tilemap 检测地表
	var surface = "default"
	if surface_detector:
		surface = surface_detector.get_surface_type(global_position)
		
	#var 

	# 默认外部倍率
	external_multiplier = 1.0
	match surface:
		"slow":
			external_multiplier = 0.3
		"grass":
			external_multiplier = 0.8
		"ground":
			external_multiplier = 1.0
		"default":
			external_multiplier = 1.0
			
	var speed_multiplier = stealth_multiplier * external_multiplier * fireball_hit_multiplier
	
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
	_play_step_sound(surface, velocity.length())
	
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hurtbox touched:", area.name)
	if is_dead:
		return
	if area.get_parent().is_in_group("Enemy"):  # check if enemy parent is in group
		#currentHealth -= 1.0 # minus 1 heart while touched the hitbox
		#healthChanged.emit(currentHealth) # show latest health status
		#heartsContainer.updateHearts(currentHealth)
		#if currentHealth <= 0:
		hit_count += 1
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.name == "SMaze":
			# SMaze get_maze_key()
			var maze_key = current_scene.get_maze_key()
			if GameState.has_collected_fragment(maze_key):
				GameState.on_escape_completed(maze_key)
				GameState.hits = hit_count
				GameState.end_time = Time.get_ticks_msec() / 1000.0
				var target_scene = "res://scenes/Endings/truth_ending.tscn"
				get_tree().call_deferred("change_scene_to_file", target_scene)
				return
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	
	anim_sprite.scale = Vector2(0.15, 0.15)
	anim_sprite.play("died")
	
	await anim_sprite.animation_finished
	change_sanity(-20)  # lose 20% on death
	if currentSanity <= 0:
		die_from_sanity()
	else:
		respawn()
	print("Player died.")
func show_game_over():
	if not is_instance_valid(gameOverUI):
		push_error("gameOverUI path is wrong")
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	gameOverUI.visible = true   # make visible
	await get_tree().process_frame
	get_tree().paused = true    # pause the rest of the game
	print("[Player] Game Over shown and tree paused")

func respawn():
	
	#maxHealth += 1
	
	#if maxHealth >= 100:
		#maxHealth = 3
		#return
		
	#currentHealth = maxHealth
	#print("Player respawn: current =", currentHealth, " max =", maxHealth)
	#heartsContainer.setMaxHearts(maxHealth, currentHealth) # show heart ui
	#heartsContainer.updateHearts(currentHealth) # update the current heart
	
	SceneSwitchAnimation.play("FadeOut")
	var spawn_point = get_tree().current_scene.gameRespawnPoint
	if spawn_point is Vector2:
		global_position = spawn_point
	elif spawn_point is Node2D:
		global_position = spawn_point.global_position
	anim_sprite.play("idle")
	anim_sprite.scale = Vector2(0.1, 0.1)
	is_dead = false
	sanityContainer.updateSanity(currentSanity) # refresh UI
	sanityLabel.text = str(round(currentSanity)) + "%"
	set_physics_process(true)

func _play_step_sound(surface: String, speed: float) -> void:
	if speed > 10:
		var ratio = speed / move_speed
		var step_interval = clamp(base_interval / ratio, min_interval, base_interval)
		step_timer -= get_physics_process_delta_time()
		
		if step_timer <= 0.0:
			step_timer = step_interval
			match surface:
				"slow":
					step_audio.stream = preload("res://assets/sounds/footsteps-on-tile-31653.mp3")
				"grass":
					step_audio.stream = preload("res://assets/sounds/walking-on-grass.mp3")
				"ground", "default":
					step_audio.stream = preload("res://assets/sounds/footstep.mp3")
			
			step_audio.pitch_scale = randf_range(0.95, 1.05)
			step_audio.play()
	else:
		step_timer = 0.0


func apply_fireball_slow():
	fireball_hit_multiplier = 0.5
	fireball_timer.start()

func _on_fireball_timer_timeout():
	fireball_hit_multiplier = 1.0
