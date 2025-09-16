extends Node2D

@onready var anim = $AnimationPlayer
@onready var label = $Label
@onready var teddy = $teddy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	await get_tree().create_timer(5).timeout
	anim.play("truth_sequence")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
