extends Node2D

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
var number_enemies = Global.number_enemies 
var current_level = 1
const  MAIN_NODE = 1

func _ready():
	
	# Connect signal
	Global.enemy_died.connect(on_enemy_died)
	spawn_enemies()
	
func spawn_enemies():
	# Columbs of enemy
	for x in range(number_enemies -1):
		var e = enemy.instantiate()
		add_child(e)
		



func on_enemy_died() -> void:
	# The number of enemies will include the main node
	# everything must take into account the extra node
	var enemies = get_tree().get_nodes_in_group("enemies") 
	print(enemies)
	print(enemies.size())

	

	if enemies.size() -2 == 0:
		current_level +=1
		level_up()
		
func level_up():
	if current_level == 2:
		print("moved to level 2")
		number_enemies = 2 + MAIN_NODE # enemies group will include the main node
		spawn_enemies()
	if current_level == 3:
		print("moved to level 3")
		number_enemies =3 + MAIN_NODE # enemies group will include the main node
		spawn_enemies()
	if current_level == 4:
		print("END OF GAME")
	
		
