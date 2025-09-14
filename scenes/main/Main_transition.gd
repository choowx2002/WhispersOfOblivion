extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gs = get_node("/root/GameState")
	gs.connect("truth_ending_triggered", Callable(self, "_on_truth_ending"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_truth_ending() -> void:
	get_tree().change_scene_to_file("res://scenes/Endings/truth_ending.tscn")
