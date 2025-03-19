extends Node


func change_scene(next_scene_dir, next_map_pos):
	var next_map = load(next_scene_dir)
	var scene_state = next_map.get_state()
	var scene_name = scene_state.get_node_name(0)
	
	# Hệ thống lưu data
	global.playerData.current_map_path = next_scene_dir
	
	# Đảm bảo việc thay đổi cảnh được thực hiện sau khi callback vật lý hoàn thành
	call_deferred("_change_scene_deferred", next_map, scene_name, next_map_pos)

func _change_scene_deferred(next_map, scene_name, next_map_pos):
	var new_scene = next_map.instantiate()
	
	# Cập nhật vị trí của Player
	new_scene.get_node("Player").global_position = next_map_pos
	
	# Xóa các scene cũ có node "Player"
	var children = get_tree().root.get_children()
	for child in children:
		if child.has_node("Player"):
			child.queue_free()

	
	# Thêm scene mới vào tree
	get_tree().get_root().call_deferred("add_child", new_scene)
	new_scene.name = scene_name  # Đặt tên cho root node của scene mới
	
	
	# Cập nhật current_scene sau khi thêm scene mới vào cây
	call_deferred("update_current_scene", new_scene)
	

func update_current_scene(new_scene):
	get_tree().current_scene = new_scene
