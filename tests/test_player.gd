extends GutTest

# Margins used by the player's clamping logic. Keep these in sync with player.gd
# (ideally expose them as constants there and reference them here).
const SIDE_MARGIN := 30.0
const BOTTOM_MARGIN := 150.0
const START_BOTTOM_OFFSET := 300.0

var player_scene: PackedScene = preload("res://scenes/player/player.tscn")
var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

var player: Node2D


func before_each():
	player = player_scene.instantiate()
	add_child_autofree(player) # GUT frees it automatically after each test
	await wait_process_frames(1)       # let _ready() and the first frame settle
	# Reset state for clean tests
	player.can_shoot = true
	player.toggle_sound = true
	player.direction = Vector2.ZERO


# --- Helpers ---------------------------------------------------------------

func _screen_size() -> Vector2:
	# Use the same call your player script uses so the numbers match.
	return get_viewport().get_visible_rect().size


func _count_nodes(node: Node) -> int:
	var total := 1
	for child in node.get_children():
		total += _count_nodes(child)
	return total


# --- Start position --------------------------------------------------------

func test_player_starts_at_bottom_center():
	var screensize := _screen_size()
	player.start()
	assert_almost_eq(player.position.x, screensize.x / 2.0, 0.01,
		"Player X should be center of screen")
	assert_almost_eq(player.position.y, screensize.y - START_BOTTOM_OFFSET, 0.01,
		"Player Y should be 300px from bottom")


# --- Shooting --------------------------------------------------------------

func test_shoot_instantiates_laser():
	# Count every node under the root so it works wherever shoot() parents the laser.
	var before := _count_nodes(get_tree().root)
	player.shoot()
	await wait_process_frames(1)
	var after := _count_nodes(get_tree().root)
	assert_gt(after, before, "Shooting should add a laser node to the tree")
	# Clean up any lasers spawned outside this test's subtree
	for node in get_tree().get_nodes_in_group("lasers"):
		node.queue_free()


func test_shoot_sets_cooldown():
	player.shoot()
	assert_false(player.can_shoot, "can_shoot should be false right after shooting")
	await wait_for_signal(player.get_node("Timer").timeout, 5)
	assert_true(player.can_shoot, "can_shoot should be restored after cooldown")


func test_shoot_blocked_during_cooldown():
	player.can_shoot = false
	var before := _count_nodes(get_tree().root)
	player.shoot() # Try to shoot during cooldown
	await wait_process_frames(1)
	var after := _count_nodes(get_tree().root)
	assert_eq(after, before, "No laser should spawn while on cooldown")
	assert_false(player.can_shoot, "can_shoot should remain false during cooldown")


# --- Movement --------------------------------------------------------------

func test_movement_clamps_left():
	player.start()
	player.speed = 1000
	player.position = Vector2(10, player.position.y)
	player.direction = Vector2(-1, 0)
	player._process(0.1)
	assert_gte(player.position.x, SIDE_MARGIN,
		"Player X should not go below %s" % SIDE_MARGIN)


func test_movement_clamps_right():
	var screensize := _screen_size()
	player.start()
	player.speed = 1000
	player.position = Vector2(screensize.x - 10, player.position.y)
	player.direction = Vector2(1, 0)
	player._process(0.1)
	assert_lte(player.position.x, screensize.x - SIDE_MARGIN,
		"Player X should not exceed viewport width - %s" % SIDE_MARGIN)


func test_movement_clamps_bottom():
	var screensize := _screen_size()
	player.start()
	player.speed = 1000
	player.position = Vector2(player.position.x, screensize.y - 10)
	player.direction = Vector2(0, 1) # +Y is DOWN in Godot
	player._process(0.1)
	assert_lte(player.position.y, screensize.y - BOTTOM_MARGIN,
		"Player Y should not exceed viewport height - %s" % BOTTOM_MARGIN)


func test_player_moves_in_direction_when_unclamped():
	player.start()
	player.speed = 100
	var start_x: float = player.position.x
	player.direction = Vector2(-1, 0)
	player._process(0.1)
	assert_lt(player.position.x, start_x, "Player should move left when direction.x is -1")


# --- Input handlers --------------------------------------------------------

func test_direction_changes_on_input_simulation():
	player.direction = Vector2.ZERO

	player._on_move_left_button_button_down()
	assert_eq(player.direction.x, -1.0, "Direction X should be -1 when moving left")

	player._on_move_left_button_button_up()
	assert_eq(player.direction.x, 0.0, "Direction X should be 0 after stopping left")

	player._on_move_right_button_button_down()
	assert_eq(player.direction.x, 1.0, "Direction X should be 1 when moving right")

	player._on_move_right_button_button_up()
	assert_eq(player.direction.x, 0.0, "Direction X should be 0 after stopping right")
