extends Area2D

# laser speed
@export var speed = Global.enemy_speed

# Set laser start position
func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta
	
	
# Kill laser if it hits a wall 
# Kill enemy if laser hits enemy
# Add to score
func _on_body_entered(body: Node2D) -> void:
	# frees the laser on a colision 
	queue_free()

	# Free body when hit by laser
	if body.is_in_group("enemies"):
		body.queue_free()
		# emit signal
		Global.enemy_died.emit()

			
		
	
			
		
		
		
