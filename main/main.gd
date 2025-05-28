extends Node2D

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
var number_enemies = Global.number_enemies 
var current_level = 1


func _ready():
	# Connect custom signal
	Global.enemy_died.connect(on_enemy_died)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	
func spawn_enemies():
	# Columbs of enemy
	for x in range(number_enemies ):
		var e = enemy.instantiate()
		add_child(e)
		
		

func on_enemy_died() -> void:
	# The number of enemies will include the main node
	# everything must take into account the extra node
	var enemies = get_tree().get_nodes_in_group("enemies") 
	print("enemy died")
	if enemies.size() -2 == 0:
		current_level +=1
		level_up()
		
func level_up():
	print("Levelup",current_level)
	if current_level == 2:
		number_enemies = (Global.number_enemies *2) 
		print("Number enemies = ",number_enemies)
		spawn_enemies()
	if current_level == 3:
		number_enemies =(Global.number_enemies *3)  
		print("Number enemies = ",number_enemies)
		spawn_enemies()
		
	if current_level == 4:
		number_enemies =(Global.number_enemies *4)  
		print("Number enemies = ",number_enemies)
		spawn_enemies()
		
	if current_level == 5:
		number_enemies =(Global.number_enemies *5)  
		print("Number enemies = ",number_enemies)
		spawn_enemies()
		
	if current_level == 6:
		print("END OF GAME")
	
		
func _on_start_button_pressed() -> void:
	# Reset game to level 1
	number_enemies = Global.number_enemies
	current_level = 1
	spawn_enemies()


func _on_ui_fire_button_pressed() -> void:
	print("fire")
	show()
