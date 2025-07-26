extends CharacterBody2D

# 玩家移动速度（单位：像素/秒）
@export var move_speed := 100

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	look_at(get_global_mouse_position())
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
 
	# 如果有输入就归一化方向，避免对角线更快
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()

	velocity = input_vector * move_speed
	move_and_slide()
