extends Node2D
# Global script
#Signals
signal enemy_died

#Vars

const  GAME_OVER_TEXT: String = "Game Over!"
var game_version = 1.01
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
	print(" Game saved!")
	save_config()
	var game_data = {
		"score": score,
		"level": level,
	}
	
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(game_data))
	file.close()
	
func load_game():
	print("Loaded saved game!")
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
	
# Save game configeration	
func save_config():
	print("Config file saved!")
	var game_data = {
		"version": game_version,
		"max_level": level,
		"enemy_value": enemy_value,
		"number_enemies": number_enemies,
		"player_speed": player_speed,
		"enemy_speed": enemy_speed,
		"shot_missed": shot_missed,
		"volume": volume,
				
	}
	
	var file = FileAccess.open("user://saveconfig.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(game_data))
	file.close()
	
func load_config():
	print("Loaded config file!")
			
	if not FileAccess.file_exists("user://saveconfig.json"):
		print("No save file found")
		return

	var file = FileAccess.open("user://saveconfig.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var config_data = JSON.parse_string(content)
	if typeof(config_data) == TYPE_DICTIONARY:
		game_version = config_data["version"]
		level = config_data["max_level"]
		enemy_value = config_data["enemy_value"]
		number_enemies = config_data["number_enemies"]
		player_speed = config_data["player_speed"]
		enemy_speed = config_data["enemy_speed"]
		shot_missed = config_data["shot_missed"]
		volume = config_data["volume"]	
		print("Loaded Config: ",config_data)		
		
	else:
		print("Failed to parse saved data")
