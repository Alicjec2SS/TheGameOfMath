extends Node

func apply_item_effect(item: InvItem) -> void:
	# Dùng call_deferred để chạy non-blocking
	call_deferred("_process_item_effect", item)

func _process_item_effect(item: InvItem) -> void:
	if item.duration > 0 and item.time_effect:
		# Hiệu ứng ngay lập tức (không theo thời gian)
		if item.add_speed_by_percentage > 0:
			global.playerData.adding_speed(item.add_speed_by_percentage, item.duration, true)
		elif item.add_speed_by_number > 0:
			global.playerData.adding_speed(item.add_speed_by_number, item.duration, false)

		# Hồi máu theo từng lần chia
		var step_time = float(item.duration) / item.effect_time_space
		for i in range(item.effect_time_space):
			await get_tree().create_timer(step_time).timeout
			global.playerData.recovery(item.add_HP_by_number, item.add_MP_by_number)
			if item.add_HP_by_percentage > 0:
				global.playerData.recovery(global.playerData.max_hp * item.add_HP_by_percentage, 0)
			if item.add_MP_by_percentage > 0:
				global.playerData.recovery(0, global.playerData.max_mp * item.add_MP_by_percentage)
	else:
		global.playerData.recovery(item.add_HP_by_number, item.add_MP_by_number)

	# Xóa item khỏi danh sách hiệu ứng nếu cần
	global.playerData.waiting_items_effect.erase(item)

