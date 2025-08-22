extends Marker2D

# This respawn point belongs to the hubroom
@export var is_main_room: bool = false

func _ready():
	# Add to groups for easier access
	if is_main_room:
		add_to_group("main_respawn")
	else:
		add_to_group("map_respawn")
