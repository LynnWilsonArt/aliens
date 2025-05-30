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
	# Free Laser
	# Check if hit enemy then 
	# remove from groug
	# free body
	# emit hit signal to main
	if body.is_in_group("enemies"):
		body.remove_from_group("enemies")
		Global.score += Global.enemy_value
		body.queue_free()
		Global.enemy_died.emit()
	if body.is_in_group("wall"):
		Global.score -= Global.enemy_value		
	# Free the laser	
	queue_free()
	
		
		

			
		
	
			
		
		
		
