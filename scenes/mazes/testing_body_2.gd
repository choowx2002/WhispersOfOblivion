extends CharacterBody2D

@onready var raycast: RayCast2D = $RayCast2D
var player: Node2D
@export var vision_range: float = 100.0  # 视野距离


func _ready() -> void:
	player = get_parent().find_child("TestingBody", true, false)

func _physics_process(delta: float) -> void:
	_update_self_visibility()

func _update_self_visibility():
	if not player:
		return
		
	var direction = (player.global_position - global_position)
	if direction.length() > vision_range:
		self.visible = false
		return

	var limited_target = direction.normalized() * vision_range
	raycast.target_position = limited_target
	raycast.force_raycast_update()

	if raycast.is_colliding() and raycast.get_collider() == player:
		self.visible = true
	else:
		self.visible = false
