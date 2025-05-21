extends ScrollContainer

# Tốc độ scroll khi nhấn phím
var scroll_speed := 20

func _process(delta):
	if Input.is_action_pressed("ui_down"):
		scroll_vertical += scroll_speed
	elif Input.is_action_pressed("ui_up"):
		scroll_vertical -= scroll_speed

	if Input.is_action_pressed("ui_right"):
		scroll_horizontal += scroll_speed
	elif Input.is_action_pressed("ui_left"):
		scroll_horizontal -= scroll_speed
