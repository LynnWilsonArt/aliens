extends GutTest

const START_NUMBER_ENEMIES := 5
const GAME_OVER_LEVEL := 6

# Global properties these tests modify; saved before and restored after each test
const GLOBAL_PROPS := ["score", "level", "number_enemies", "game_over"]

var main_scene: PackedScene = preload("res://scenes/main/main.tscn")
var enemy_scene: PackedScene = preload("res://scenes/enemy/enemy.tscn")

var main_node: Node2D
var _saved_global := {}


# --- Helpers ----------------------------------------------------------------

func _save_global() -> void:
	_saved_global.clear()
	for p in GLOBAL_PROPS:
		_saved_global[p] = Global.get(p)


func _reset_global() -> void:
	Global.score = 0
	Global.level = 1
	Global.number_enemies = START_NUMBER_ENEMIES
	Global.set("game_over", false)


func _restore_global() -> void:
	for p in GLOBAL_PROPS:
		Global.set(p, _saved_global[p])


## Count live enemy instances spawned under main (ignores nodes queued for deletion).
func _count_enemies() -> int:
	var count := 0
	for child in main_node.get_children():
		if child.scene_file_path == enemy_scene.resource_path \
				and not child.is_queued_for_deletion():
			count += 1
	return count


## Free every enemy under main and wait a frame so they leave the "enemies" group.
func _kill_all_enemies() -> void:
	for child in main_node.get_children():
		if child.scene_file_path == enemy_scene.resource_path:
			child.queue_free()
	await wait_process_frames(1)


# --- Setup & Teardown -------------------------------------------------------

func before_each():
	_save_global()
	_reset_global()
	# main.gd captures Global.level / Global.number_enemies when instantiated,
	# so Global must be reset BEFORE instantiating.
	main_node = main_scene.instantiate()
	add_child_autofree(main_node)
	await wait_process_frames(1)
	# _ready() calls Global.load_config() and Global.load_game(), which may have
	# overwritten Global from a save file. Put everything back to a known state.
	_reset_global()
	main_node.current_level = Global.level
	main_node.number_enemies = Global.number_enemies


func after_each():
	_restore_global()


# --- Initialization ---------------------------------------------------------

func test_main_starts_with_correct_defaults():
	assert_eq(main_node.current_level, 1, "Initial level should be 1")
	assert_eq(main_node.number_enemies, START_NUMBER_ENEMIES,
		"Initial enemy count should match Global")


func test_game_over_label_hidden_on_start():
	assert_false(main_node.get_node("ColorRect/GameOverLabel").visible,
		"Game Over label should be hidden after _ready()")


func test_no_enemies_before_start():
	assert_eq(_count_enemies(), 0, "No enemies should exist until the game starts")


# --- spawn_enemies ----------------------------------------------------------

func test_spawn_enemies_creates_enemies():
	var before := _count_enemies()
	main_node.spawn_enemies()
	assert_gt(_count_enemies(), before, "spawn_enemies should add enemies")


func test_spawn_enemies_creates_correct_count():
	main_node.spawn_enemies()
	assert_eq(_count_enemies(), START_NUMBER_ENEMIES,
		"Should spawn exactly number_enemies enemies")


# --- level_up ---------------------------------------------------------------

func test_level_up_scales_enemy_count_per_level():
	# level_up() does NOT increment the level; it reads current_level.
	# Level N spawns Global.number_enemies * N enemies.
	for level in range(1, GAME_OVER_LEVEL):
		var before := _count_enemies()
		main_node.current_level = level
		main_node.level_up()
		assert_eq(_count_enemies() - before, START_NUMBER_ENEMIES * level,
			"Level %d should spawn %d enemies" % [level, START_NUMBER_ENEMIES * level])
		assert_eq(Global.level, level, "level_up should sync Global.level to %d" % level)


func test_level_up_at_game_over_level_shows_game_over_and_spawns_nothing():
	main_node.current_level = GAME_OVER_LEVEL
	main_node.level_up()
	assert_true(main_node.get_node("ColorRect/GameOverLabel").visible,
		"Game Over label should be visible at level %d" % GAME_OVER_LEVEL)
	assert_eq(_count_enemies(), 0, "No enemies should spawn at the game over level")


func test_level_up_below_game_over_level_does_not_show_game_over():
	main_node.current_level = GAME_OVER_LEVEL - 1
	main_node.level_up()
	assert_false(main_node.get_node("ColorRect/GameOverLabel").visible,
		"Game Over should not show before level %d" % GAME_OVER_LEVEL)


# --- on_enemy_died ----------------------------------------------------------

func test_on_enemy_died_levels_up_when_all_dead():
	main_node.current_level = 1
	main_node.level_up() # spawns level 1 enemies
	assert_eq(_count_enemies(), START_NUMBER_ENEMIES)

	await _kill_all_enemies()
	assert_eq(get_tree().get_nodes_in_group("enemies").size(), 0,
		"Precondition: no enemies should remain in the 'enemies' group")

	Global.enemy_died.emit()
	assert_eq(main_node.current_level, 2, "current_level should increment immediately")

	await wait_process_frames(1) # level_up is call_deferred
	assert_eq(Global.level, 2, "Global.level should be 2 after the deferred level_up")
	assert_eq(_count_enemies(), START_NUMBER_ENEMIES * 2,
		"Level 2 should spawn double the enemies")


func test_on_enemy_died_does_not_level_up_while_enemies_remain():
	main_node.current_level = 1
	main_node.level_up()

	# Kill just one enemy
	for child in main_node.get_children():
		if child.scene_file_path == enemy_scene.resource_path:
			child.queue_free()
			break
	await wait_process_frames(1)
	assert_gt(get_tree().get_nodes_in_group("enemies").size(), 0,
		"Precondition: surviving enemies must be in the 'enemies' group")

	Global.enemy_died.emit()
	await wait_process_frames(1)
	assert_eq(main_node.current_level, 1, "Level should not change while enemies remain")


func test_killing_last_enemy_on_level_5_triggers_game_over():
	main_node.current_level = 5
	main_node.level_up()
	await _kill_all_enemies()

	Global.enemy_died.emit()
	assert_eq(main_node.current_level, GAME_OVER_LEVEL)
	await wait_process_frames(1) # deferred level_up -> game_over
	assert_true(main_node.get_node("ColorRect/GameOverLabel").visible,
		"Game Over should show after clearing the final level")


# --- _on_start_button_pressed -----------------------------------------------

func test_start_button_syncs_level_and_spawns_enemies():
	Global.level = 3
	main_node.current_level = 0 # deliberately out of sync

	main_node._on_start_button_pressed()

	assert_eq(main_node.current_level, 3, "current_level should sync with Global.level")
	assert_eq(_count_enemies(), START_NUMBER_ENEMIES * 3,
		"Level 3 should spawn triple the enemies")


# --- game_over --------------------------------------------------------------

func test_game_over_shows_label_with_correct_text():
	var label = main_node.get_node("ColorRect/GameOverLabel")
	label.hide()

	main_node.game_over()

	assert_true(label.visible, "Game Over label should be visible after game_over()")
	assert_eq(label.text, Global.GAME_OVER_TEXT, "Label should show the game over text")


func test_game_over_plays_sound():
	var sound = main_node.get_node("ColorRect/Level/GameOverSound")
	main_node.game_over()
	if sound.stream == null:
		pending("GameOverSound has no stream assigned, so 'playing' can't be checked")
		return
	assert_true(sound.playing, "GameOverSound should be playing after game_over()")


# --- _process (score/level display) -----------------------------------------

func test_process_updates_score_display():
	Global.score = 42
	main_node._process(0.0)
	assert_eq(main_node.get_node("ColorRect/Score").text, "42",
		"Score label should show the current score")


func test_process_updates_level_display():
	Global.level = 3
	main_node._process(0.0)
	assert_eq(main_node.get_node("ColorRect/Level").text, "3",
		"Level label should show the current level")
