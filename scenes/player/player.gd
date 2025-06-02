extends Area2D
@export var speed = Global.player_speed
@export var cooldown = 0.25
@export var laser_scene : PackedScene = preload("res://scenes/laser/laser.tscn")
var can_shoot = true
var direction = Vector2.ZERO
signal start_game
var toggle_sound = true

# Get viewport size
@onready var screensize = get_viewport_rect().size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Move ship to starting position
	start()
	

# Move player to the bottom center of screen
func start():
	position = Vector2(screensize.x / 2, screensize.y - 300)
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
	if toggle_sound:
		laser_blast_sound("play")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle android hud input
	# Set player position	
	position += direction * speed * delta
	
	# Keep player in viewport clamp(top Vector(),bottom Vector()
	position = position.clamp(Vector2(30,30), screensize - Vector2(30,150))
	# Fire laser	
	if Input.is_action_pressed("shoot"):
		shoot()
			
	
# Laser shooting delay timer
# after times out sets can dhoot to true
func _on_timer_timeout() -> void:
	can_shoot = true


func _on_hud_fire_laser() -> void:
	shoot()


# send start signal to main for game start
func _on_start_button_pressed() -> void:
	$HUD/StartButton.hide()
	start_game.emit()


func _on_move_left_button_button_down() -> void:
	if toggle_sound:
		tank_move_sound("play")		
	direction = Vector2(-1.0,0.0)


func _on_move_left_button_button_up() -> void:
	if toggle_sound:
		tank_move_sound("stop")		
	direction = Vector2(0.0,0.0)

func _on_move_right_button_button_down() -> void:
	if toggle_sound:
		tank_move_sound("play")
	direction = Vector2(1.0,0.0)

func _on_move_right_button_button_up() -> void:
	if toggle_sound:
		tank_move_sound("stop")
	direction = Vector2(0.0,0.0)

func _on_button_quit_pressed() -> void:
	# sends out notification that app is going to quit
	Global.save_game()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = 'https://lynnwilsonart.com/games-beta';")
	else:
		get_tree().quit()


func _on_reset_game_button_pressed() -> void:
	Global.reset_game()
	
func tank_move_sound(action):
	if action == "play":
		$TankMoveSound.play()
	else:
		$TankMoveSound.stop()
		
func laser_blast_sound(action):
	if action == "play":
		$LaserBlastSound.play()
	else :
		$LaserBlastSound.stop()
		


func _on_sound_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$HUD/SoundButton.text = "Sound On"
		toggle_sound = true
	else :
		$HUD/SoundButton.text = "Sound Off"
		toggle_sound = false
