extends Node2D
#Signals
signal enemy_died

#Vars
const SCORE_CAL = 5
const  GAME_OVER_TEXT: String = "Game Over!"
var score = SCORE_CAL # calabrate for first run problem.
var enemy_value = 5
var enemy_speed = -3000
var number_enemies = 5       
var player_speed = 800
var game_over = false
