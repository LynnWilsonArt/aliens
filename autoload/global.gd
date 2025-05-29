extends Node2D
#Signals
signal enemy_died

#Vars
var score = 0 + 5 # 5 is to correct error and adjust value back to 0 on game start
var enemy_value = 5
var enemy_speed = -3000
var number_enemies = 5          
var player_speed = 800
var game_over = false
