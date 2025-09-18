extends Node2D

@onready var anim = $AnimationPlayer
@onready var label = $Label
@onready var teddy = $teddy
@onready var clear_pic = $Background/NinePatchRect
@onready var SceneSwitchAnimation = $SceneSwitchAnimation/AnimationPlayer
@onready var result = $Background/NinePatchRect/ResultScreen
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	clear_pic.visible = false
	await get_tree().create_timer(5).timeout
	anim.play("truth_sequence")

	_show_clear_pic()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _show_clear_pic() -> void:
	await get_tree().create_timer(27).timeout
	SceneSwitchAnimation.play("FadeOut")
	await SceneSwitchAnimation.animation_finished
	clear_pic.visible = true
	await get_tree().create_timer(2).timeout
	result.visible = true
	var time_taken = GameState.end_time - GameState.start_time
	result.set_results(GameState.hits, GameState.respawns, time_taken)
