extends Panel

@onready var sprite: Sprite2D = $Sprite2D

func update(_filled: bool):
	sprite.frame = 0
