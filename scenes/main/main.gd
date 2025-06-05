extends Node2D
# Main script

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
var number_enemies = Global.number_enemies 
var current_level = Global.level
var end_of_game_text = Global.GAME_OVER_TEXT



func _ready():
	Global.load_config()
	Global.load_game()	
	# play intro and set volume
	#$AudioStreamPlayer2D.play()
	#$AudioStreamPlayer2D.volume_db = Global.volume

	# Hide game over test
	OS.request_permission("android.permission.ACTION_OPEN_DOCUMENT")
	$ColorRect/GameOverLabel.hide()
	
	print("Game loaded: ","Level  ",Global.level,"  Score: ",Global.score)
	# Connect custom signal
	Global.enemy_died.connect(on_enemy_died)


func _process(_delta: float) -> void:
	# Display score
	$ColorRect/Score.text = str(Global.score)
	$ColorRect/Level.text = str(Global.level)
	
func spawn_enemies():
	# Columbs of enemy
	print("starting enemies: ",number_enemies)
	for x in range(number_enemies ):
		var e = enemy.instantiate()
		add_child(e)		

func on_enemy_died() -> void:
	# The number of enemies will include the main node
	# everything must take into account the extra node
	var enemies = get_tree().get_nodes_in_group("enemies").size()

	if enemies == 0:
		current_level +=1
		level_up()
		
func level_up():
	if current_level == 1:
		number_enemies = (Global.number_enemies ) 
		Global.level = current_level
		spawn_enemies()
	if current_level == 2:
		number_enemies = (Global.number_enemies *2) 
		Global.level = current_level
		spawn_enemies()
		
	if current_level == 3:
		number_enemies =(Global.number_enemies *3)  
		Global.level = current_level
		spawn_enemies()
		
	if current_level == 4:
		number_enemies =(Global.number_enemies *4)  
		Global.level = current_level
		spawn_enemies()
		
	if current_level == 5:
		number_enemies =(Global.number_enemies *5)  
		Global.level = current_level
		spawn_enemies()
		
	if current_level == 6:
		game_over()
		
		
func _on_start_button_pressed() -> void:
	
	print("level: ",current_level,"Global level",Global.level)
	print("GEnemy",Global.number_enemies," num_enemy",number_enemies)
	current_level = Global.level
	level_up()
	

func game_over():
	# Game over
	$ColorRect/GameOverLabel.text = end_of_game_text
	$ColorRect/GameOverLabel.show()
	$ColorRect/Level/GameOverSound.play()
	
