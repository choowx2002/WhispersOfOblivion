extends Area2D

@export var target_scene: String

func _on_body_entered(body):
	if body.name == "TestingBody":
		get_tree().call_deferred("change_scene_to_file", "res://scenes/hub/HubRoom.tscn")
