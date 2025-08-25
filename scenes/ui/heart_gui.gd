extends Panel

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	pass
	
func _process(delta):
	pass
	
func update(whole: bool):
	if whole: 
		sprite.frame = 12
	else: 
		sprite.frame = 13
