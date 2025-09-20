extends Sprite2D

@onready var north_item = $"../NorthItem"
@onready var south_item = $"../SouthItem"
@onready var east_item = $"../EastItem"
@onready var west_item = $"../WestItem"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide all items initially
	self.visible = false
	
	# Get maze direction from node name
	var direction = name.trim_suffix("Item").to_lower()
	
	# Check if fragment is collected
	if GameState.has_collected_fragment(direction):
		self.visible = true
	else:
		self.visible = false
	print("DEBUG: ", direction, " fragment visibility: ", self.visible)
	
	# Connect to fragment collection signal to update display
	if not GameState.is_connected("fragment_collected", _on_fragment_collected):
		GameState.connect("fragment_collected", _on_fragment_collected)

func _on_fragment_collected(maze_key: String):
	var direction = name.trim_suffix("Item").to_lower()
	if maze_key == direction:
		self.visible = true
		print("DEBUG: Showing ", direction, " fragment")
