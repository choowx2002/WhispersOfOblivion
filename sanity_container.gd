extends HBoxContainer

@onready var SanityGuiClass = preload("res://scenes/ui/sanity_gui.tscn")

var maxSanity: float = 100.00
var currentSanity: float = 100.00

func setMaxSanity(max: float, current: float):
	maxSanity = max
	currentSanity = current
	clear()
	for i in range(int(maxSanity / 10)):
		var sanity = SanityGuiClass.instantiate()
		add_child(sanity)
	updateSanity(currentSanity)
	
func updateSanity(current: float):
	currentSanity = clamp(current, 0 ,maxSanity)
	var sanity_bars = get_children()
	var filled = int((currentSanity / maxSanity) * sanity_bars.size())
	for i in range(sanity_bars.size()):
		sanity_bars[i].update(i < filled)
		
func clear():
	for child in get_children():
		child.queue_free()
	
	
