extends Node2D

# Main program entry 
# initalize some vars
var enemy = preload("res://scenes/enemy/enemy.tscn")
@export var num_enemies = 3
@export var game_level = 1
# Initilize score
@export var score = 0
# Set initial value of enemy for level 1
@export var enemy_value = 5


func _ready():
	
	
	# Set gamve level spawn_enemies() 
	num_enemies = num_enemies * game_level
	spawn_enemies()
	
	
	
func spawn_enemies():
	# Columbs of enemy
	for x in range(num_enemies):
		var e = enemy.instantiate()
		add_child(e)
