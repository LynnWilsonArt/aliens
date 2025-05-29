extends Area2D

# laser speed
@export var speed = Global.enemy_speed

# Set laser start position
func start(pos):
	position = pos
	
# Velocity of laser
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
		# emit signal & free enemy
		Global.score += Global.enemy_value
		Global.enemy_died.emit()
		body.queue_free()
		
	if body.is_in_group("wall"):
		Global.score -= Global.enemy_value
		Global.enemy_died.emit()
		
		

			
		
	
			
		
		
		
