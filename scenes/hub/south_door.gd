extends Area2D

var StoryLabelScene = preload("res://scenes/ui/story_label.tscn")
var ConfirmationPanelScene = preload("res://scenes/ui/confirmation_panel.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
		
	# Check if all other fragments are collected
	var has_north = GameState.has_collected_fragment("north")
	var has_east = GameState.has_collected_fragment("east")
	var has_west = GameState.has_collected_fragment("west")
	
	# Count collected fragments
	var collected_count = 0
	var missing_fragments = []
	# North Frag
	if has_north: collected_count += 1
	else: missing_fragments.append("North")
	# East Frag
	if has_east: collected_count += 1
	else: missing_fragments.append("East")
	# West Frag
	if has_west: collected_count += 1
	else: missing_fragments.append("West")
	print("DEBUG: Collected Frags: ", collected_count)

	# Different messages based on progression
	var message = ""
	match collected_count:
		0:
			message = "Not yet… I don’t think I’m ready… maybe I need to find something first."
		1:
			message = "It feels strange… I’m missing something… what was it again?"
		2:
			message = "Hmm… I think I forgot something… I should look for the others."
	
	# By default, can't enter the maze
	GameState.playerSelectedRoom = ""
	
	# Show the message with appropriate handling
	var story_label = StoryLabelScene.instantiate()
	get_tree().root.add_child(story_label)
	
	if has_north and has_east and has_west:
		message = "The shadows here... they're different... why do they make my heart ache?"
		story_label.fade_completed.connect(show_confirmation_dialog)
		# Set shorter timing for final quotes
	story_label.display_time = 1.5
	story_label.fade_in_time = 0.5
	story_label.show_story(message)

func show_confirmation_dialog() -> void:
	var panel = ConfirmationPanelScene.instantiate()
	# Set process mode to always to allow input while paused
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(panel)
	panel.get_node("Panel/VBoxContainer/Label").text = "Are you ready to face your final maze?"
	# Connect signals
	panel.confirmed.connect(_on_confirmation_confirmed)
	panel.cancelled.connect(_on_confirmation_cancelled)

func _on_confirmation_confirmed() -> void:
	# Directly change to the maze scene
	get_tree().change_scene_to_file("res://scenes/mazes/S_Maze.tscn")

func _on_confirmation_cancelled() -> void:
	GameState.playerSelectedRoom = ""

func _on_body_exited(body: Node2D) -> void:
	if body.name != "TestingBody":
		return
	GameState.playerSelectedRoom = ""
