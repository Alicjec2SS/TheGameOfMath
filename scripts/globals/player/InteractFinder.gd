extends Area2D

var entities_in_interacts_area = []

func cssort(enti1,enti2):
	var e1 = $"..".global_position.distance_to(enti1.global_position)
	var e2 = $"..".global_position.distance_to(enti2.global_position)
	return e1 < e2

func _process(_delta):
	if Input.is_action_just_pressed("interact") and len(entities_in_interacts_area) > 0 and !global.is_interacting:
		entities_in_interacts_area.sort_custom(cssort)
		entities_in_interacts_area[0].interact()
		
func _on_body_exited(body):
	if not body.has_method('player') and body.has_method("interact"):
		var index = entities_in_interacts_area.find(body)
		if index != -1:
			entities_in_interacts_area.remove_at(index)


func _on_body_entered(body):
	if not body.has_method('player') and body.has_method("interact"):
		entities_in_interacts_area.append(body)


