extends Area2D

@export var StoryLabelScene = preload("res://scenes/ui/story_label.tscn")
var player_inside: bool = false
var body_ref: Node2D = null # track player body
var story_label: Node = null

func _on_body_entered(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
		
	player_inside = true
	body_ref = body
	
	story_label = StoryLabelScene.instantiate()
	get_tree().root.add_child(story_label)
	
	story_label.display_time = 1.5
	story_label.fade_in_time = 0.5
	story_label.show_story("The maze looks frozen… something is waiting, I think.")
	story_label.fade_completed.connect(_on_fade_completed)

func _on_fade_completed() -> void:
	if player_inside and is_instance_valid(body_ref):
		GameState.playerSelectedRoom = "res://scenes/mazes/N_Maze.tscn"
		body_ref.show_interact_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
	player_inside = false
	
	if is_instance_valid(body_ref):
		body_ref.hide_interact_prompt()
	
	GameState.playerSelectedRoom = ""
	body_ref = null

func _exit_tree() -> void:
	# cleanup when this Area2D is removed from the tree
	player_inside = false
	body_ref = null
	GameState.playerSelectedRoom = ""
	
	if story_label:
		if story_label.fade_completed.is_connected(_on_fade_completed):
			story_label.fade_completed.disconnect(_on_fade_completed)
		story_label.queue_free()
		story_label = null
