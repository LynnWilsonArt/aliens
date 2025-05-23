extends Area2D
@export var speed = 150
@export var cooldown = 0.25
@export var laser_scene : PackedScene = preload("res://scenes/laser/laser.tscn")
var can_shoot = true
# Get viewport size
@onready var screensize = get_viewport_rect().size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Move ship to starting position
	start()
	

# Move ship to the bottom center of screen
func start():
	position = Vector2(screensize.x / 2, screensize.y - 64)
	$Timer.wait_time = cooldown

# Shoot the laser
func shoot():
	if not can_shoot:
		return
	can_shoot = false
	# start the no can shoot timer
	$Timer.start()
	
	# Instantiate the laser
	var l = laser_scene.instantiate()
	get_tree().root.add_child(l)	
	l.start(position + Vector2(0,-55))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move player ship
	var input = Input.get_vector("left", "right", "up", "down")
	
	# Set ship position	
	position += input * speed * delta
	
	# Keep ship in viewport clamp(top Vector(),bottom Vector()
	position = position.clamp(Vector2(30,30), screensize - Vector2(30,60))
	# Fire laser	
	if Input.is_action_pressed("shoot"):
		shoot()
	
# Laser shooting delay timer
func _on_timer_timeout() -> void:
	can_shoot = true
