extends AnimatedSprite2D

func _process(delta):
	if has_meta("velocity"):
		position += get_meta("velocity") * delta

	rotation += sin(Time.get_ticks_msec() / 200.0 + hash(self)) * 0.005

	var viewport_rect = get_viewport().get_visible_rect()
	if not viewport_rect.has_point(global_position):
		queue_free()
