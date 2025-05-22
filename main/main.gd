extends Node2D

var enemy = preload("res://enemy/enemy.tscn")
var score = 0


func _ready():
	spawn_enemies()
	
func spawn_enemies():
	# Columbs of enemy
	for x in range(5):
		var e = enemy.instantiate()
		add_child(e)
