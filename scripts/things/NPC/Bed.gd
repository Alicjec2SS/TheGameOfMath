extends CharacterBody2D


@export var player:CharacterBody2D


func exit_dialog(arg: String):
	if arg == 'quited':
		global.movement_disable = false
		global.can_interact = true
	if arg == "sleep":
		var anim = player.get_node("Transition")
		var miniUI_anim = player.get_node("UI/anim")
		
		anim.play("fade_out")
		miniUI_anim.play("end")
		global.save_game_data()
		await get_tree().create_timer(2).timeout
		
		
		#change time to perfectly 6:00 AM,or 1/2 PI
		global.playerData.time = (global.playerData.day * (2*PI)) + 1.57
		global.can_move = true
		global.is_interacting = false
		
		anim.play("fade_in")
		miniUI_anim.play("show")
		await get_tree().create_timer(1).timeout
		
func interact():
	global.can_move = false
	global.is_interacting = true
	Dialogic.start('sleeping')
	if not Dialogic.signal_event.is_connected(exit_dialog):
		Dialogic.signal_event.connect(exit_dialog)

