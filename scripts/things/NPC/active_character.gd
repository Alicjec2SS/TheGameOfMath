extends CharacterBody2D



#lỗi do cs
@export var artID = 0
@export var dialog_tree = 'gaylordchatting'
@export var after_battle_dialog_tree = "gaylordchatting"
@export var state = 'down_idle'
@export var can_be_moving = false
@export var movement_spd = 0.7
@export var go_anim_play = AnimationPlayer.new()
@export var time_to_go = 0.0
@export var side_to_go = 'down'


@export var is_battle = false
@export var battle_ID_self = 911
@export var trantroi = "Oh f**k u are so strong"
@export var health = 3
@export var XP = 90
@export var money = 99
@export var levelQuest = 1



var have_finish = false
var player_state
var prevdir
var cs = false
var is_seen = false

func _ready():
	$AnimatedSprite2D.play(str(artID)+"_"+state)
func exit_dialog(arg: String):
	if arg == 'quit':
		global.can_move = true
		global.is_interacting = false
		#print("ID: "+ str(battle_ID_self) + "|Is Battle: " + str(is_battle))
		$AnimatedSprite2D.play(str(artID)+"_"+state)
		get_node('/root/'+get_tree().current_scene.name+'/Player').anchor = prevdir
		if is_battle:
			if not battle_ID_self in global.playerData.defeated_ID_player:
				global.can_move=false
				global.is_interacting=true
				var battle_scene = get_node("/root/"+get_tree().current_scene.name+"/Player/Battle")
				battle_scene.opponent_health = health
				battle_scene.tran_troi = trantroi
				battle_scene.chat_tree = []
				battle_scene.opponentID = battle_ID_self
				battle_scene.EXP = XP
				battle_scene.money = money
				battle_scene.level_question = levelQuest
				battle_scene.heart_left = global.playerData.HP
				battle_scene.show()
				global.can_move = false
				global.is_interacting = true
		
func _process(delta):
	#print(global.is_interacting)
	#print(global.playerData.HP)
	if battle_ID_self in global.playerData.defeated_ID_player:
		return
	if self.has_node('RayCast2D') and not have_finish:
		var collider = self.get_node('RayCast2D').get_collider()
		if collider and collider.has_method('player'):
			if not is_seen:
				is_seen = true
				global.can_move = false
				global.is_interacting = true
				_change_face_to_opposite(true)
				have_finish = true
				go_anim_play.play('go')
				self.get_node('AnimatedSprite2D').play(str(artID)+ "_" +side_to_go)
				global.can_move = false
				global.is_interacting = true
				await get_tree().create_timer(time_to_go).timeout
			else:
				is_seen = false
func interact():
	#converting the side
	_change_face_to_opposite(false)
	global.can_move=false
	global.is_interacting=true
	if is_battle:
		if battle_ID_self in global.playerData.defeated_ID_player:
			Dialogic.start(after_battle_dialog_tree)
		else:
			Dialogic.start(dialog_tree)
			
	else:
		Dialogic.start(dialog_tree)
	if not Dialogic.signal_event.is_connected(exit_dialog):
		Dialogic.signal_event.disconnect(exit_dialog)
		Dialogic.signal_event.connect(exit_dialog)
	else:
		Dialogic.signal_event.connect(exit_dialog)


func _change_face_to_opposite(NPCmoving):
	var a = ""  # Khởi tạo a để tránh Nil
	prevdir = get_node('/root/'+get_tree().current_scene.name+'/Player').anchor
	player_state = get_node('/root/'+get_tree().current_scene.name+'/Player').global_position
	
	# Kiểm tra vị trí của player so với NPC
	if player_state.x > self.global_position.x + 16:
		a = 'right_idle'
	elif player_state.x < self.global_position.x - 16:
		a = 'left_idle'
	elif player_state.y < self.global_position.y - 16:
		a = 'up_idle'
	elif player_state.y > self.global_position.y + 16:
		a = 'down_idle'
	
	# Nếu a vẫn là "", đặt giá trị mặc định để tránh lỗi
	if a == "":
		a = state # hoặc trạng thái mặc định khác

	# Chuyển hướng cho player
	var player = get_node('/root/'+get_tree().current_scene.name+'/Player')
	if a == 'right_idle':
		player.anchor = 'left'
	elif a == 'left_idle':
		player.anchor = 'right'
	elif a == 'up_idle':
		player.anchor = 'down'
	elif a == 'down_idle':
		player.anchor = 'up'

	# Phát animation NPC nếu không di chuyển hoặc đã hoàn thành hành động
	if !NPCmoving or have_finish:
		$AnimatedSprite2D.play(str(artID) + "_" + a)

		
		
func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		have_finish = true  # Ngăn NPC di chuyển
		go_anim_play.pause()
		$AnimatedSprite2D.play(str(artID)+"_"+state)
		cs = true
		
		if not global.is_interacting and not battle_ID_self in global.playerData.defeated_ID_player:
			print("Fuck you bitch")
			interact()
