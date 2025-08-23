extends Panel

@onready var sprite = $Sprite2D
func _ready():
	pass
	
func _process(delta):
	pass
	
func update(whole: bool):
	if whole: sprite.frame = 7
	else: sprite.frame = 8
