extends Node2D

@onready var anim = $AnimationPlayer
@onready var label = $Label
@onready var teddy = $teddy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	teddy.visible = false
	label.text = ""
	anim.play("truth_sequence")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_anim_finished(anim_name: String) -> void:
	if anim_name == "truth_sequence":
		# Fade to morning light, then wake-up scene
		get_tree().change_scene_to_file("res://scenes/endings/wake_up_truth.tscn")
