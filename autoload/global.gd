extends Node2D
#Signals
signal enemy_died

#Vars
var game_version = 1.01
var debug: bool = true
const  GAME_OVER_TEXT: String = "Game Over!"
var volume = 10 # sets volume to +2 db
var score: int = 0
var level: int = 1
var enemy_value: int = 5
var enemy_speed = -3000
var number_enemies: int = 5  
var player_speed: int = 800
var game_over: bool = false
var shot_missed: int = 1
var is_saved_game: bool = false

# Save game state
func save_game():
	var game_data = {
		"score": score,
		"level": level,
	}
	
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(game_data))
	file.close()
	
func load_game():
			
	if not FileAccess.file_exists("user://savegame.json"):
		print("No save file found")
		return

	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var game_data = JSON.parse_string(content)
	if typeof(game_data) == TYPE_DICTIONARY:
		# Apply data to your game (e.g., player position, score)
		score = game_data["score"]
		level = game_data["level"]
		if score > 0:
			is_saved_game = true
			
		
	else:
		print("Failed to parse saved data")
		
func reset_game():
	score = 0
	level = 1
	save_game()
