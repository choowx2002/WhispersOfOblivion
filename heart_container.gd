extends HBoxContainer

@onready var HeartGuiClass = preload("res://scenes/ui/heart_gui.tscn")

var maxHealth: float = 0
var currentHealth: float = 0
func _ready():
	pass
	
func _process(delta):
	pass
	
func setMaxHearts(max: float, current: float):
	maxHealth = max
	currentHealth = current
	for child in get_children():
		child.queue_free()
	for i in range(maxHealth):
		var heart = HeartGuiClass.instantiate()
		add_child(heart)
	updateHearts(currentHealth)
		
func updateHearts(current: float):
	currentHealth = clamp(current, 0, maxHealth)
	var hearts = get_children()
	for i in range(hearts.size()):
		if i < currentHealth:
			hearts[i].update(true)   # full
		else:
			hearts[i].update(false)  # empty

		
func clear():
	for child in get_children():
		child.queue_free()
