extends Area2D

@export var path_to_next_map = "res://scenes/level2.tscn"
@export var next_map_pos:Vector2 = Vector2(0,0)


func _on_body_entered(body):
	if body.has_method("player"):
		global.can_move = false
		body.get_node("Transition").play("fade_out")
		body.get_node("UI/anim").play("end")
		await get_tree().create_timer(1).timeout
		Transporter.change_scene(path_to_next_map,next_map_pos)
		
