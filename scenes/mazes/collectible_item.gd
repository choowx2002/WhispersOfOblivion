extends Area2D

@export var item_id: String = "memory_fragment"
@export var auto_pickup: bool = true  # 自动捡还是按键

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name != "TestingBody":
		return

	if auto_pickup:
		_collect()
	else:
		set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		_collect()

func _collect():
	print("player collec item")
	queue_free()
