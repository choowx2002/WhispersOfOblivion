extends CharacterBody2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 150

func _physics_process(delta):
	position += direction * speed * delta
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		if collision.get_collider().is_in_group("player"):
			collision.get_collider().apply_fireball_slow()
		queue_free()


func _on_screen_exited() -> void:
	queue_free()
