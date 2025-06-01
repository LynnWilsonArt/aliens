extends Area2D

# laser speed
@export var speed = Global.enemy_speed

# Set laser start position
func start(pos):
	position = pos
	
# Velocity of laser
func _process(delta):
	position.y += speed * delta
		
# Enemy was hit
func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("enemies"):
		# play explosion animation
		body.remove_from_group("enemies")
		Global.score += Global.enemy_value
		print("Laser -> ", Global.score)
		body.queue_free()
		Global.enemy_died.emit()
	
	# not enemy hit reduce score
	if body.is_in_group("wall") && Global.score == 0:
		print(" score in: ",Global.score)
		# do nothing
		return
	elif Global.is_saved_game:
		Global.is_saved_game = false
		return
	elif body.is_in_group("wall") && Global.score > 0:
		# reduce score
		Global.score -= Global.shot_missed
		print(" score out: ",Global.score)
	
	# Free the laser	
	queue_free()
	
		
		

			
		
	
			
		
		
		
