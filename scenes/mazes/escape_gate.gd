extends Area2D

@export var target_scene: String = "res://scenes/hub/HubRoom.tscn"

func _on_body_entered(body):
	# Ignore enemies or NPCs touching the gate
	if body.name != "TestingBody":
		return  
	
	var maze_key := ""
	var scene := get_tree().current_scene
	
	# Check Maze
	if scene and scene.has_method("get_maze_key"):
		maze_key = scene.get_maze_key()
	
	# If the memory fragment from this maze is collected, mark maze as done
	if GameState.has_collected_fragment(maze_key):
		GameState.on_escape_completed(maze_key)
	else:
		print("No memory fragment collected for", maze_key)
	
	# Teleport back to the hub
	get_tree().call_deferred("change_scene_to_file", target_scene)
