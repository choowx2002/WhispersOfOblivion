extends Area2D

var StoryLabelScene = preload("res://scenes/ui/story_label.tscn")
var player_inside: bool = false
var body_ref: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
		
	player_inside = true
	body_ref = body
	
	var story_label = StoryLabelScene.instantiate()
	get_tree().root.add_child(story_label)
	story_label.display_time = 1.5
	story_label.fade_in_time = 0.5
	story_label.show_story("The maze looks frozen… something is waiting, I think.")
	story_label.fade_completed.connect(func():
		if player_inside and is_instance_valid(body_ref):
			GameState.playerSelectedRoom = "res://scenes/mazes/N_Maze.tscn"
			body_ref.show_interact_prompt()
	)

func _on_body_exited(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
	player_inside = false
	
	if is_instance_valid(body_ref):
		body_ref.hide_interact_prompt()
	
	GameState.playerSelectedRoom = ""
	body_ref = null
