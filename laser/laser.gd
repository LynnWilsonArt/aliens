extends Area2D
# laser speed
@export var speed = -3000 




# Set laser start position
func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta
	
	
# Kill laser if hits enemy
func _on_body_entered(body: Node2D) -> void:
	print(body)
	# free laser
	queue_free()
	if ! body.is_in_group("wall"):
		body.queue_free()
