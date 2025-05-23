extends Area2D
# Laser code

signal enemy_dead

# laser speed
@export var speed = -3000 

# Set laser start position
func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta
	
	
# Kill laser if it hits a wall 
# Kill enemy if laser hits enemy
# Add to score
func _on_body_entered(body: Node2D) -> void:
	print("killed enemy")
	
	# free laser
	queue_free()
	# free laser if it hits wall
	if ! body.is_in_group("wall"):
		body.queue_free()
		
		
