extends Area2D

func _on_body_entered(body: Node2D) -> void:
	GameState.playerSelectedRoom = "res://scenes/mazes/N_Maze.tscn"

func _on_body_exited(body: Node2D) -> void:
	GameState.playerSelectedRoom = ""
