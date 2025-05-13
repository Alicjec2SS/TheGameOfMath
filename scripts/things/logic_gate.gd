extends Area2D

@export_group("Basic Information")
@export var anim:AnimatedSprite2D
@export var path_to_next_map = "res://scenes/level2.tscn"
@export var next_map_pos:Vector2 = Vector2(0,0)


@export_group("Inventory")
@export var active_if_picked_item_in_inventory:bool = false
@export var item:int = -1
@export var consumable_after_using:bool=false

@export_group("Defeated")
@export var active_if_a_NPC_defeated:bool=false
@export var NPC:int = -1

@export_group("Stats")
@export var active_if_stats_satisfied:bool=false
@export var level_required:int = -1
@export var day_required:int = -1
@export var time_required:Array[float]# example, for 6.a.m to 8.30 p.m(or 20.30 ) we will let this [6,20.5]

const min_in_day = 1440
const min_in_hour = 60
const ingame1day = (2*PI)/min_in_day

#time function
func recalc() -> Array:
	var total_min = int(global.playerData.time / ingame1day)
	global.playerData.day = int(total_min/min_in_day)+1
	var cur_day_min = total_min % min_in_day
	var hour = int(cur_day_min / min_in_hour)
	var min = cur_day_min - hour*min_in_hour
	return [min,hour,global.playerData.day]

func _on_body_entered(body):
	if body.has_method("player") and should_activate():
		global.can_move = false
		body.get_node("Transition").play("fade_out")
		body.get_node("UI/anim").play("end")
		await get_tree().create_timer(1).timeout
		Transporter.change_scene(path_to_next_map,next_map_pos)
	elif not should_activate():
		print("Access denied")
		
		
		
func should_activate() -> bool:
	# Điều kiện 1: Item trong inventory
	if active_if_picked_item_in_inventory and item != -1:
		if item not in global.playerData.inventory:
			return false

	# Điều kiện 2: NPC đã bị đánh bại
	if active_if_a_NPC_defeated and NPC != -1:
		if NPC not in global.playerData.defeated_ID_player:
			return false

	# Điều kiện 3: Kiểm tra level và ngày
	if active_if_stats_satisfied:
		if level_required > 0 and global.playerData.lVL < level_required:
			return false
		if day_required > 0 and global.playerData.day < day_required:
			return false

		# Kiểm tra giờ trong ngày
		if time_required.size() == 2:
			var time_info = recalc()
			var hour = time_info[1]
			var minute = time_info[0]
			var current_time = hour + float(minute)/60.0
			if current_time < time_required[0] or current_time > time_required[1]:
				return false

	# Nếu tất cả đều ổn
	return true
