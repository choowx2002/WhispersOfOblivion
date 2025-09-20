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
	
	# Only mark as collected if the fragment was picked up
	if GameState.has_picked_up_fragment(maze_key) and not GameState.has_collected_fragment(maze_key):
		print("Fragment Collected on Escape: ", maze_key)
		GameState.mark_fragment_collected(maze_key)
		GameState.on_escape_completed(maze_key)
	else:
		print("Fragment not picked up or already collected: ", maze_key)
	
	# Teleport back to the hub
	get_tree().call_deferred("change_scene_to_file", target_scene)
