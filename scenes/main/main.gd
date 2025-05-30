extends Node2D
# Main script

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
var number_enemies = Global.number_enemies 
var current_level = 1
var end_of_game = Global.GAME_OVER_TEXT



func _ready():
	# Hide game over test
	$ColorRect/GameOver.hide()
	
	# Connect custom signal
	Global.enemy_died.connect(on_enemy_died)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _process(delta: float) -> void:
	# Display score
	$ColorRect/Score.text = str(Global.score)
	$ColorRect/Level.text = str(current_level)
	
func spawn_enemies():
	# Columbs of enemy
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
	if current_level == 2:
		number_enemies = (Global.number_enemies *2) 
		spawn_enemies()
		
	if current_level == 3:
		number_enemies =(Global.number_enemies *3)  
		spawn_enemies()
		
	if current_level == 4:
		number_enemies =(Global.number_enemies *4)  
		spawn_enemies()
		
	if current_level == 5:
		number_enemies =(Global.number_enemies *5)  
		spawn_enemies()
		
	if current_level == 6:
		# Game over
		$ColorRect/GameOver.text = end_of_game
		$ColorRect/GameOver.show()
	
		
func _on_start_button_pressed() -> void:
	# Reset game to level 1
	number_enemies = Global.number_enemies
	current_level = 1
	spawn_enemies()

	
