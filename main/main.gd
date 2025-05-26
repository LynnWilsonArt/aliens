extends Node2D

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
var number_enemies = Global.number_enemies
var current_level = 1

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

	number_enemies -= 1
	print("enemy")
	print(number_enemies)

	if number_enemies == 0:
		current_level +=1
		level_up()
		
func level_up():
	if current_level == 2:
		print("level")
		print(current_level)
		number_enemies = 2
		spawn_enemies()
	if current_level == 3:
		print("level")
		print(current_level)
		number_enemies =3
		spawn_enemies()
	
		
