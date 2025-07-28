extends Area2D

func _on_body_entered(body: Node2D) -> void:
	GameState.playerSelectedRoom = "res://scenes/mazes/E_Maze.tscn"

func _on_body_exited(body: Node2D) -> void:
	GameState.playerSelectedRoom = ""
