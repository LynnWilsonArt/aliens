extends CanvasLayer
signal start_game
signal move_right
signal move_left
signal fire_laser

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_fire_laser_pressed() -> void:
	fire_laser.emit()


func _on_move_left_button_pressed() -> void:
	move_left.emit()

func _on_move_right_button_pressed() -> void:
	move_right.emit()
