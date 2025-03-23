extends CharacterBody2D

@export var artID = 0
@onready var Anim = $AnimatedSprite2D
@export var dialog_tree = 'gaylordchatting'
@export var after_battle_dialog_tree = "gaylordchatting"
@export var is_battle = false
@export var battle_ID_self = 911
@export var trantroi = "Oh f**k u are so strong"
@export var health = 3
@export var XP = 90
@export var money = 99
@export var levelQuest = 1

#global.playerData.defeated_ID_player


# Called when the node enters the scene tree for the first time.
func _ready():
	Anim.play(str(artID))

func exit_dialog(arg: String):
	if arg == 'quit':
		global.can_move = true
		global.is_interacting = false
		if is_battle:
			if not battle_ID_self in global.playerData.defeated_ID_player:
				global.can_move = false
				global.is_interacting = true
				var battle_scene = get_node("/root/"+get_tree().current_scene.name+"/Player/Battle")
				battle_scene.opponent_health = health
				battle_scene.tran_troi = trantroi
				battle_scene.chat_tree = []
				battle_scene.opponentID = battle_ID_self
				battle_scene.EXP = XP
				battle_scene.money = money
				battle_scene.level_question = levelQuest
				battle_scene.show()

				

func interact():
	global.can_move = false
	global.is_interacting = true
	if is_battle:
		if battle_ID_self in global.playerData.defeated_ID_player:
			Dialogic.start(after_battle_dialog_tree)
		else:
			Dialogic.start(dialog_tree)
			
	else:
		Dialogic.start(dialog_tree)
	if not Dialogic.signal_event.is_connected(exit_dialog):
		Dialogic.signal_event.connect(exit_dialog)
